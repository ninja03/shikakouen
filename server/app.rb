require 'json'
require "tempfile"
require 'sinatra'
require "sinatra/json"
require 'cairo'
require 'rmagick'

def load_sample_question
  JSON.load(File.read('question.json'), nil, symbolize_names: true, create_additions: false)
end

def quantize_to_grayscale(value, levels)
  step = 255 / (levels - 1)
  ((value / step).round) * step
end

def read_image()
  Tempfile.create do |f|
    image = Magick::Image.read("deno_news.png").first

    image = image.resize_to_fit(256,256)

    image = image.quantize(4, Magick::GRAYColorspace)

    image.write(f.path)

    # original = Cairo::ImageSurface.from_png("deno_news.png");

    # scale= 256.0 /  [original.width, original.height].max
    # new_width = (original.width * scale).to_i
    # new_height = (original.height * scale).to_i

    # scaled = Cairo::ImageSurface.new(original.format, new_width, new_height)

    # # 新しいサイズに描画するためのContextを作成
    # context = Cairo::Context.new(scaled)

    # # スケールを設定して元の画像を描画
    # context.scale(scale, scale)
    # context.set_source(original, 0, 0)
    # context.paint

    # # グレースケール変換
    # # 新しい画像サーフェスを作成
    # grayscale = Cairo::ImageSurface.new(scaled.format, new_width, new_height)
    # context = Cairo::Context.new(grayscale)

    # # p scaled.data[0]

    # # 元の画像の各ピクセルを処理
    # new_width.times do |x|
    #   new_height.times do |y|
    #     # pixel_str = scaled.data[y * new_width + x]
    #     # p pixel_str.
    #     # pixel=pixel_str.sub('\x', '').to_i(16)

    #     pixel = scaled.get_pixel(x,y)
    #     p(pixel)

    #     if y>30
    #       break
    #     end
    #     # RGBの値を取得
    #     r = (pixel >> 16) & 0xff
    #     g = (pixel >> 8) & 0xff
    #     b = pixel & 0xff

    #     # グレースケール値を計算（輝度計算）
    #     gray = (0.299 * r + 0.587 * g + 0.114 * b).to_i

    #     # 4つのレベルに量子化
    #     quantized_gray = quantize_to_grayscale(gray, 4)

    #     # 新しいグレースケール値をセット
    #     context.set_source_rgb(quantized_gray / 255.0, quantized_gray / 255.0, quantized_gray / 255.0)
    #     context.rectangle(x, y, 1, 1)
    #     context.fill
    #   end
    #   break
    # end

    # scaled.write_to_png(f.path)
    content_type :png
    File.binread(f.path)
  end
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
  3.times do
    kata = katalist.sample
    dir = [:left, :right, :down, :up].sample
    px = rand(0..(board[0].size - kata[0].size))
    py = rand(0..(board.size - kata.size))
    board = katanuki(board, kata, px, py, dir)
  end
  board
end

def create_random_question
  board_width = 10
  board_height = 10

  goal = [
    [0,0,0,0,0,0,0,0,0,0],
    [0,1,1,1,1,1,1,1,1,0],
    [0,1,0,0,0,0,0,0,0,0],
    [0,1,0,0,0,0,0,0,0,0],
    [0,1,0,0,0,0,0,0,0,0],
    [0,1,0,0,0,0,0,0,0,0],
    [0,1,0,0,0,0,0,0,0,0],
    [0,1,0,0,0,0,0,0,0,0],
    [0,1,1,1,1,1,1,1,1,0],
    [0,0,0,0,0,0,0,0,0,0]
  ]
  katalist = []
  general_patterns = (1..2).map do |i|
    pattern_width = rand(2..2)
    pattern_height = rand(2..2)
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
  goal.each do |a|
    copy_goal.push(a.dup)
  end
  start = shuffle_board(copy_goal, katalist)

  $question = {
    board: {
      width: board_width,
      height: board_height,
      start: start.map { |a| a.join },
      goal: goal.map { |a| a.join }
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

$colors = ["lightgray", "black", "red", "blue"]

get '/image/start' do
  board = $question[:board]
  read_image
  # create_image(board[:width], board[:height], board[:start], $colors)
end

get "/image/goal" do
  board = $question[:board]
  create_image(board[:width], board[:height], board[:goal], $colors)
end

get "/image/pattern/:p" do
  pattern = $question[:general][:patterns].find do |p|
    p[:p] == params[:p].to_i
  end
  colors = ["lightgray", "black"]
  create_image(pattern[:width], pattern[:height], pattern[:cells], colors)
end
