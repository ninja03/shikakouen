require 'json'
require "tempfile"
require 'sinatra'
require "sinatra/json"
require 'cairo'
require 'rmagick'

def load_sample_question
  JSON.load(File.read('question.json'), nil, symbolize_names: true, create_additions: false)
end

class Board
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def width = @data[0].size
  def height = @data.size

  def self.from_file(filename)
    Tempfile.create do |f|
      img = Magick::Image.read(filename).first.resize_to_fit(256, 256).quantize(4, Magick::GRAYColorspace)
      pixels = img.get_pixels(0, 0, img.columns, img.rows).map{ |pixel| pixel.to_hsla[2] }
      pixel_table = pixels.uniq.sort.map.with_index { |pixel, i| [pixel.to_s, i] }.to_h
      data = pixels.map { |pixel| pixel_table[pixel.to_s] }.each_slice(img.columns).to_a
      Board.new(data)
    end
  end
end

def create_image(data)
  board_width = data[0].size
  board_height = data.size
  colors = ["black", "gray", "lightgray", "white"]
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

def katanuki(board, kata, px, py, dir)
  kh = kata.length
  kw = kata[0].length
  bh = board.length
  bw = board[0].length

  new_board = []
  case dir
  when :left
    bh.times do |y|
      normal_buf = []
      kata_buf = []
      bw.times do |x|
        a = board[y][x]
        if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1
          kata_buf << a
        else
          normal_buf << a
        end
      end
      new_board << normal_buf + kata_buf
    end
  when :right
    bh.times do |y|
      normal_buf = []
      kata_buf = []
      bw.times do |x|
        a = board[y][x]
        if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1
          kata_buf << a
        else
          normal_buf << a
        end
      end
      new_board << kata_buf + normal_buf
    end
  when :down
    bw.times do |x|
      normal_buf = []
      kata_buf = []
      bh.times do |y|
        a = board[y][x]
        if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1
          kata_buf << a
        else
          normal_buf << a
        end
      end
      new_board << kata_buf + normal_buf
    end
    new_board = new_board.transpose
  when :up
    bw.times do |x|
      normal_buf = []
      kata_buf = []
      bh.times do |y|
        a = board[y][x]
        if x >= px and x < px + kw and y >= py and y < py + kh and kata[y - py][x - px] == 1
          kata_buf << a
        else
          normal_buf << a
        end
      end
      new_board << normal_buf + kata_buf
    end
    new_board = new_board.transpose
  end
  new_board
end

def shuffle_board(board, katalist)
  10.times do
    kata = katalist.sample
    dir = [:left, :right, :down, :up].sample
    px = rand(0..(board[0].size - kata[0].size))
    py = rand(0..(board.size - kata.size))
    board = katanuki(board, kata, px, py, dir)
  end
  board
end

def create_random_question
  goal = Board.from_file("deno_news.png")
  katalist = []
  general_patterns = (1..10).map do |i|
    pattern_width = rand(2..goal.width / 3)
    pattern_height = rand(2..goal.height / 3)
    cells = Array.new(pattern_height) { Array.new(pattern_width) { rand(2) } }
    katalist << cells
    {
      p: 25 + i,
      width: pattern_width,
      height: pattern_height,
      cells: cells.map { |a| a.join }
    }
  end
  copy_goal = []
  goal.data.each do |a|
    copy_goal.push(a.dup)
  end
  start = shuffle_board(copy_goal, katalist)

  $question = {
    board: {
      width: goal.width,
      height: goal.height,
      start: start.map { |a| a.join },
      goal: goal.data.map { |a| a.join }
    },
    general: {
      n: general_patterns.size,
      patterns: general_patterns
    }
  }
end

configure do
  # $question = load_sample_question
  $question = create_random_question
end

get "/" do
  @question = $question
  erb :index
end

get "/random" do
  @question = create_random_question
  redirect "/"
end

get '/api/question' do
  json $question
end

post '/api/answer' do
  params = JSON.parse(request.body.read)
end

get '/image/start' do
  create_image($question[:board][:start])
end

get "/image/goal" do
  create_image($question[:board][:goal])
end

get "/image/pattern/:p" do
  pattern = $question[:general][:patterns].find do |p|
    p[:p] == params[:p].to_i
  end
  create_image(pattern[:cells])
end
