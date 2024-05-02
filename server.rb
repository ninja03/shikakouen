require 'sinatra'
require 'json'

get '/' do
  file = File.read('question.json')
  sample_data = JSON.load(file)
  content_type :json
  sample_data.to_json
end
