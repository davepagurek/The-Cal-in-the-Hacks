#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'net/http'

require_relative 'west_side.rb'

AUDIO_URI = 'https://stream.watsonplatform.net'

builder = WestSide::Builder.new

get '/sample_words' do
  content_type :json
  {words: builder.words_sample.to_a}.to_json
end

post '/generate' do
  content_type :json
  data = JSON.parse(request.body.read)

  {lines: builder.build(data["seed"])}.to_json
end

get '/' do
  content_type :html
  File.new('public/index.html').readlines
end

post '/gen_audio' do
  content_type: json
  poem = JSON.parse(request.body.read)
  uri = URI.parse(AUDIO_URI)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new('/text-to-speech/api/v1/synthesize')
  request.body = {
                  'credentials' => { 'username' => ENV['username'], 'key' => ENV['key'] },
                  'text' => poem
                 }
  response = http.request(request)
end
