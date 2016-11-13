#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'net/http'
require 'securerandom'

require_relative 'west_side.rb'

AUDIO_URI = 'https://stream.watsonplatform.net'

builder = WestSide::Builder.new

def file_age(name)
  (Time.now - File.ctime(name))/(60*60)
end

def cleanup!
  Dir.glob('public/audio/*.wav').each do |filename|
    if file_age(filename) > 1
      puts "Deleting #{filename}"
      File.delete(filename)
    end
  end
end

get '/sample_words' do
  content_type :json
  {words: builder.words_sample.to_a}.to_json
end

post '/generate' do
  content_type :json
  data = JSON.parse(request.body.read)

  poem = builder.build(data["seed"], data["seussify"])
  uuid = SecureRandom.uuid
  Kernel.system "curl -X POST -u 183647eb-7c6b-4942-8669-03c4b9379bb9:h3edpLwXlaxR " +
                 "--header 'Content-Type: application/json' " +
                 "--header 'Accept: audio/wav' " +
                 "--data '{\"text\": #{poem.join(', ').inspect.gsub("'", "\\'") }}' " +
                 "'https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize' > public/audio/poem#{uuid}.wav"
  cleanup!
  { lines: poem, file: "/audio/poem#{uuid}.wav" }.to_json

end

get '/' do
  content_type :html
  File.new('public/index.html').readlines
end

get '/audio/*' do |file|
  send_file "public/audio/#{file}"
end

post '/gen_audio' do
  content_type :json
  poem = JSON.parse(request.body.read)
  uri = URI.parse(AUDIO_URI)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new('/text-to-speech/api/v1/synthesize')
  request.body = {
                  'credentials' => { 'username' => ENV['username'], 'key' => ENV['key'] },
                  'text' => poem
                 }
  response = http.request(request)
  response
end
