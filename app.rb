require 'fileutils'
require 'sinatra/cross_origin'
require 'faraday'


#todo: https://github.com/britg/sinatra-cross_origin

$blobby_port = ENV['BLOBBY_PORT_4000_TCP_PORT']
$blobby_addr = ENV['BLOBBY_PORT_4000_TCP_ADDR']

class DocTrack < Sinatra::Base
#  reset!
#  use Rack::Reloader
  
  before do
     content_type  = 'text/plain'
     headers  'Access-Control-Allow-Origin' => '*', 
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
              'Access-Control-Allow-Headers' => 'Content-Type'              
  end

  set :protection, false

  def sanatize(raw_body)
    raw_body.
      gsub(/(gliffy-[^\s]*-)\d*/,'\1').
      gsub(/\s+gliffy-active/,'').
      gsub(/(class="[^"]*)\s+"/,'\1"')
      
  end
  
  ### Forwards the call to the Blobby
  post '/docs' do
    conn = Faraday.new(:url => "http://#{$blobby_addr}:#{$blobby_port}") do |c|
      c.use Faraday::Request::UrlEncoded  # encode request params as "www-form-urlencoded"
      c.use Faraday::Response::Logger     # log request & response to STDOUT
      c.use Faraday::Adapter::NetHttp     # perform requests with Net::HTTP
    end

    response = conn.post '/files', { :filename => params[:filename], :body => sanatize(params[:body])}  
    status = response.status
    return response.body
  end
  
  
  ### simple web interface
  get '/' do
    """
    <html><body>
    <h1> Doc Track </h1>
    <h2>Get FingerPrint</h2>
    <form action='/docs' method='post' enctype='multipart/form-data'>
    Filename: <input type='text' name='filename' /><br/>
    Body: <textarea name='body' rows='20' cols='80'></textarea>
    <input type='submit' value='Send'></input>
    </form>
    </body></html>
    """
  end
  
   
end
