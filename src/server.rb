require 'sinatra'

get '/' do
  send_file '../public/app/index.html'
end


get '/download/:name/:url/:os' do
  send_file '../public/app/index.html'
end
