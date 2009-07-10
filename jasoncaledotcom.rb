require 'rubygems'

$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')

require 'sinatra'
require 'haml'
require 'sass'

require File.join(File.dirname(__FILE__), 'lib', 'jasoncaledotcom')
require File.join(File.dirname(__FILE__), 'lib', 'help_me_out')


set :public, 'public'
set :views,  'views'

include Jasoncaledotcom

get '/' do  
  @articles = Article.all
  haml :index
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/articles/:id' do
  @article = Article.open("articles/#{params[:id]}")
  haml :show
end

