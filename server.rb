#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require_relative 'west_side.rb'

@builder = WestSide::Builder.new

get '/sample_words' do
  content_type :json
  {sample_words: @builder.words_sample.to_a}
end

post '/generate' do
  content_type :json
  data = JSON.parse(request.body.read)["seed"]

  {verses: @builder.build(data.seed, data.syllables)}
end
