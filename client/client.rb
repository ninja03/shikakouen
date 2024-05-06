require 'json'
require 'net/http'

def print_board(board)
  puts board.map{|row| row.join(' ')}
  puts
end

def katanuki(board, kata, px, py, dir)
  kh = kata.length
  kw = kata[0].length
  bh = board.length
  bw = board[0].length

  new_board = []
  case dir
  when 'left'
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
  when 'right'
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
  when 'down'
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
  when 'up'
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

puts 'nara procon system'
puts

uri = URI.parse('http://localhost:4567/api/question')
json = Net::HTTP.get(uri)
json_data = JSON.parse(json)

board = json_data['board']['start'].map{ |row| row.split("").map(&:to_i) }
kata = json_data['general']['patterns'][0]['cells'].map{ |row| row.split("").map(&:to_i) }

puts 'board'
print_board board
puts 'kata'
print_board kata
puts 'left'
new_board = katanuki(board, kata, 1, 2, 'left')
print_board new_board
puts 'right'
new_board = katanuki(board, kata, 1, 2, 'right')
print_board new_board
puts 'down'
new_board = katanuki(board, kata, 1, 2, 'down')
print_board new_board
puts 'up'
new_board = katanuki(board, kata, 1, 2, 'up')
print_board new_board

uri = URI.parse('http://localhost:4567/answer')
json = Net::HTTP.post(
  uri,
  { key: 'value' }.to_json,
  'Content-Type' => 'application/json'
)
