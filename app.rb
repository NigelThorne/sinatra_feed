
 
# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'sinatra/base'
require 'fileutils'
require 'sinatra/cross_origin'
 
require 'open-uri'
# Application:::::::::::::::::::::::::::::::::::::::::::::::::::
require_relative "sass_handler"
require_relative "coffee_handler"

 
class MyApp < Sinatra::Base
  reset!
  use Rack::Reloader
  use SassHandler
  use CoffeeHandler

  before do
     content_type  = 'text/plain'
     headers  'Access-Control-Allow-Origin' => '*', 
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
              'Access-Control-Allow-Headers' => 'Content-Type'              

  end

  # Configuration:::::::::::::::::::::::::::::::::::::::::::::::
  set :public, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'
  set :protection, false
  # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::

  get '/' do
    @author = "Nigel Thorne"
    @year = Time.now.year
    slim :index
  end

  post '/recipe' do
    recipe_html_string = open(params["recipe_url"]).read

    @recipe = Hangry.parse(recipe_html_string)
    @ingredients = @recipe.ingredients.map{
      |ingredient|
      Ingreedy.parse(ingredient)
    }

    slim :recipe
  end
        
end
 
if __FILE__ == $0
    MyApp.run! :port => 4567
end
