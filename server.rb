require 'sinatra'
require 'json'

get '/question' do
  file = File.read('question.json')
  sample_data = JSON.load(file)
  content_type :json
  sample_data.to_json
end

post '/answer' do
  params = JSON.parse(request.body.read)
  print params
end
