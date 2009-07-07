require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), 'vendor', 'sinatra', 'lib')
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'jasoncaledotcom')

set :public, 'public'
set :views,  'views'

get '/' do
  @articles = Article.all
  haml :index
end

get '/:id' do
end

