
 
# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'sinatra/base'
require 'fileutils'
require 'sinatra/cross_origin'
 
 require 'ostruct'
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
  set :public_dir, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'
  set :protection, false
  enable :sessions
  # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::

  def require_logged_in
    redirect('/sessions/new') unless is_authenticated?
  end
   
  def is_authenticated?
    return !!session[:user_id]
  end
   
  get '/' do
    slim :login
  end
   
  get '/sessions/new' do
    slim :login
  end
   
  post '/sessions' do
    session[:user_id] = params["user_id"]
    redirect('/meal_plan')
  end
   
  get '/meal_plan' do
    require_logged_in
    slim :meal_plan
  end

  post '/shopping_list' do
    urls = params["recipe_url"].values.reject{|v| v.nil? || v.empty? }
    @verbose_ingredients = urls.flat_map{|u| ingredients(u) }
    @grouped_ingredients = @verbose_ingredients.group_by{|i| [i.ingredient, i.unit]}
    @ingredients = @grouped_ingredients.map{|k,v| OpenStruct.new({ingredient: k[0], unit:k[1], amount:v.inject(0){|a,t| a+t.amount}})}
    slim :shopping_list
  end

  # TODO.. take into account head count
  def ingredients(url)
    recipe_html_string = open(url).read

    recipe = Hangry.parse(recipe_html_string)
    ingredients = recipe.ingredients.map{
      |ingredient|
      Ingreedy.parse(ingredient)
    }
  end
  # get '/' do
  #   @author = "Nigel Thorne"
  #   @year = Time.now.year
  #   slim :index
  # end

  post '/recipe' do
    recipe_html_string = open(params["recipe_url"]).read

    @recipe = Hangry.parse(recipe_html_string)
    @verbose_ingredients = @recipe.ingredients.flat_map{
      |ingredient|
      Ingreedy.parse(ingredient)
    }
    @grouped_ingredients = @verbose_ingredients.group_by{|i| [i.ingredient, i.unit]}
    @ingredients = @grouped_ingredients.map{|k,v| v[0].amount = v.inject{|a,t| t+a.amount}}
    raise @ingredients.inspect
    slim :recipe
  end
        
end
 
if __FILE__ == $0
    MyApp.run! :port => 4567
end
