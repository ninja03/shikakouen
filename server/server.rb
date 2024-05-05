require 'sinatra'
require 'json'

$question = JSON.load(File.read('question.json'))

get "/" do
  @question = $question
  erb :index
end

get "/sample" do
  $question = JSON.load(File.read('question.json'))
  pp $question
  redirect "/"
end

get "/random" do
  width = rand(32..256)
  height = rand(32..256)
  start = Array.new(height) { Array.new(width) { rand(4) }.join }
  goal = Array.new(height) { Array.new(width) { rand(4) }.join }
  general_n = rand(3)
  general_patterns = []

  general_i = 25
  for i in 0..general_n
    pattern_width = rand(1..10)
    pattern_height = rand(1..10)
    general_patterns << {
      "p" => general_i,
      "width" => pattern_width,
      "height" => pattern_height,
      "cells" => Array.new(pattern_height) { Array.new(pattern_width) { rand(2) }.join }
    }
    general_i += 1
  end

  $question = {
    "board" => {
      "width" => width,
      "height" => height,
      "start" => start,
      "goal" => goal
    },
    "general" => {
      "n" => general_n,
      "patterns" => general_patterns
    }
  }

  pp $question

  redirect "/"
end

get '/api/question' do
  content_type :json
  $question.to_json
end

post '/api/answer' do
  params = JSON.parse(request.body.read)
  print params
end
