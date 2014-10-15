require 'fileutils'
require 'sinatra/cross_origin'
require 'faraday'

#todo: https://github.com/britg/sinatra-cross_origin

$blobby_port = ENV['BLOBBY_PORT_4000_TCP_PORT']
$blobby_addr = ENV['BLOBBY_PORT_4000_TCP_ADDR']

class DocTrack < Sinatra::Base
  reset!
  use Rack::Reloader
  
  before do
     content_type  = 'text/plain'
     headers  'Access-Control-Allow-Origin' => '*', 
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
              'Access-Control-Allow-Headers' => 'Content-Type'              
  end

  set :protection, false

  post '/page' do
    conn = Faraday.new(:url => 'http://#{$blobby_addr}:#{$blobby_port}') do |c|
      c.use Faraday::Request::UrlEncoded  # encode request params as "www-form-urlencoded"
      c.use Faraday::Response::Logger     # log request & response to STDOUT
      c.use Faraday::Adapter::NetHttp     # perform requests with Net::HTTP
    end

    response = conn.post '/files', { :filename => params[:filename], :body => params[:body]}  
    status = response.status
    return response.body
  end
   
end
