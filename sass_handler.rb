class SassHandler < Sinatra::Base
    
  set :views, File.dirname(__FILE__) + '/templates/sass'
  Sass.load_paths <<  File.dirname(__FILE__) + '/templates/sass'   

  get '/css/*.css' do
    filename = params[:splat].first
    sass filename.to_sym
  end
    
end
