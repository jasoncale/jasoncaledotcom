require 'rubygems'

$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')

require 'sinatra'
require 'haml'
require 'sass'

require File.join(File.dirname(__FILE__), 'lib', 'jasoncaledotcom')

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

get '/:id' do
end

