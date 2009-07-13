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

before do
  domain = 'http://jasoncale.com'
  
  if (!env['HTTP_HOST'] =~ /localhost/) && env['HTTP_HOST'] =~ /www/
    redirect domain
    return false
  else
  
    if !(request.path_info =~ /.css/)
      @last_fm_tracks = LastFm::Track.recent
      @tweet = Tweet.latest
    end

    response.headers['Cache-Control'] = 'public, max-age=300'
  end
end

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
  if @article
    haml :show
  else
    haml :not_found
  end
end

# get '/rss.xml' do
#   @articles = Article.all
#   
#   builder do |xml|
#     xml.instruct! :xml, :version => '1.0'
#     xml.rss :version => "2.0" do
#       xml.channel do
#         xml.title "Jason Cale :: Young Delta Heart"
#         xml.description "Ruby developer :: UI Designer"
#         xml.link "http://jasoncale.com/"
#         
#         title, body, date, permalink
#         
#         @articles.each do |article|
#           xml.item do
#             xml.title article.title
#             xml.link "http://jasoncale.com/articles/#{article.permalink}"
#             xml.description article.body
#             xml.pubDate Time.parse(post.date.to_s).rfc822()
#             xml.guid "http://jasoncale.com/articles/#{article.permalink}"
#           end
#         end
#       end
#     end
#   end
# end