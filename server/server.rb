require 'json'
require "tempfile"
require 'sinatra'
require "sinatra/json"
require 'cairo'

def load_sample_question
  JSON.load(File.read('question.json'), nil, symbolize_names: true, create_additions: false)
end

configure do
  $question = load_sample_question
end

get "/" do
  @question = $question
  erb :index
end

get "/sample" do
  $question = load_sample_question
  redirect "/"
end

get "/random" do
  board_width = rand(32..256)
  board_height = rand(32..256)
  start = Array.new(board_height) { Array.new(board_width) { rand(4) }.join }
  goal = Array.new(board_height) { Array.new(board_width) { rand(4) }.join }
  general_patterns = (1..rand(1..3)).map do |i|
    pattern_width = rand(1..10)
    pattern_height = rand(1..10)
    {
      p: 25 + i,
      width: pattern_width,
      height: pattern_height,
      cells: Array.new(pattern_height) { Array.new(pattern_width) { rand(2) }.join }
    }
  end

  $question = {
    board: {
      width: board_width,
      height: board_height,
      start: start,
      goal: goal
    },
    general: {
      n: general_patterns.size,
      patterns: general_patterns
    }
  }

  redirect "/"
end

get '/api/question' do
  json $question
end

post '/api/answer' do
  params = JSON.parse(request.body.read)
end

get '/image/start' do
  board = $question[:board]
  colors = ["pink", "lightblue", "lightgreen", "orange"]
  create_image(board[:width], board[:height], board[:goal], colors)
end

get "/image/goal" do
  board = $question[:board]
  colors = ["pink", "lightblue", "lightgreen", "orange"]
  create_image(board[:width], board[:height], board[:goal], colors)
end

get "/image/pattern/:p" do
  pattern = $question[:general][:patterns].find do |p|
    p[:p] == params[:p].to_i
  end
  colors = ["lightgray", "black"]
  create_image( pattern[:width], pattern[:height], pattern[:cells], colors)
end

def create_image(board_width, board_height, data, colors)
  Tempfile.create do |f|
    ps = 4
    surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, board_width * ps, board_height * ps)
    context = Cairo::Context.new(surface)
    board_height.times do |y|
      board_width.times do |x|
        context.set_source_color(colors[data[y][x].to_i])
        context.rectangle(x * ps, y * ps, ps, ps)
        context.fill
      end
    end
    surface.write_to_png(f.path)
    content_type :png
    File.binread(f.path)
  end
end
