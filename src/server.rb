require 'sinatra'
require 'tempfile'
require "net/http"
require 'fileutils'
require 'uri'
require "cgi"
require 'digest'

configure do
  enable :logging
end

FileUtils::mkdir_p('dist')
FileUtils::touch('dist/out.txt')

get '/' do
  send_file '../public/index.html'
end

get '/download' do
  log "in /download"
  platform, arch = params[:os].split('-')
  url = params[:url]
  name = params[:name]

  log url
  log platform

  file_path = create_app url, name, platform, arch
  log file_path
  send_file file_path
end



get '/check' do
  url = params[:url]
  log url
  filename ="./dist/#{url}"
  log "Downloading #{filename}"
  send_file(filename, :type => "application/zip")
end




def create_app(url, name, platform, arch)
  if url_invalid? url
    return "ERROR #{url}"
  end

  tmp_folder_path = setup_tmp_dir()

  find_and_replace_in_file("#{tmp_folder_path}/package.json", 'your-app', name)
  find_and_replace_in_file("#{tmp_folder_path}/main.js", 'https://www.example.com/', url)

  # replacement is to make sure the url http://google.com does not create a two directories
  url_hash = Digest::hexencode url
  log url_hash
  output_dir = "./dist/#{url_hash}"
  log output_dir
  electron_app_folder_name = "#{output_dir}/#{name}-#{platform}-#{arch}"

  output = `electron-packager #{tmp_folder_path} #{name} --platform=#{platform} --arch=#{arch} --out=#{output_dir} --version=1.3.3 --overwrite`
  output = `zip -rqy #{electron_app_folder_name}.zip #{electron_app_folder_name} >> dist/out.txt`


  #TODO: some thread should take care of the deleting
  FileUtils::rm_r tmp_folder_path
  FileUtils::rm_r electron_app_folder_name

  return "#{electron_app_folder_name}.zip"
end

def url_invalid?(url)
  output = `curl -s -m 5 --head #{url} | head -n 1`
  return output.empty? || output.include?("404")
end

def find_and_replace_in_file(filepath, word, replacement_word)
  text = File.read(filepath)
  text = text.gsub(word, replacement_word)
  File.open(filepath, "w") do |f|
    f.write(text)
  end
end

def setup_tmp_dir
  uuid_folder = SecureRandom.uuid
  tmp_folder_path = "../tmp/#{uuid_folder}"
  FileUtils::mkdir_p "#{tmp_folder_path}"
  FileUtils::cp_r '../resource/.', "#{tmp_folder_path}"
  return tmp_folder_path
end


def log(text)
  `echo #{text} >> dist/out.txt`
end
