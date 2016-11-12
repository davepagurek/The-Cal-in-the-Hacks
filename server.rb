#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require_relative 'west_side.rb'

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
