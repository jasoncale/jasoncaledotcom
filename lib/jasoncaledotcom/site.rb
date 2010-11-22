require "sinatra/base"
require "sinatra/reloader"
require "sprockets"
require "less"
require "haml"
require "jasoncaledotcom/helpers"
require "jasoncaledotcom/sprockets_renderer"

module Jasoncaledotcom
  class Site < Sinatra::Base
    autoload :Article, 'jasoncaledotcom/site/article'
    include SprocketsRenderer    
    
    configure :development do
      enable :logging, :dump_errors, :raise_errors
      set :show_exceptions, true
    end

    configure :production do
      enable :logging
      not_found do
        haml :not_found
      end

      error do
        haml :error
      end
    end
    
    configure do
      set :public, 'public'
      set :views,  'views'
    end
    
    before do
      if production?
        domain = 'jasoncale.com'

        if !(env['HTTP_HOST'] =~ /local|^#{domain}/)
          redirect "http://#{domain}"
        else        
          response.headers['Cache-Control'] = 'public, max-age=300'
        end
      end
    end
    
    # resources
    
    get '/style.css' do
      content_type 'text/css', :charset => 'utf-8'
      less :stylesheet
    end
    
    get '/sprockets.js' do
      render_sprockets
    end
    
    # pages
    
    get '/' do
      @articles = Article.published      
      haml :index
    end

    get '/articles' do
      redirect Article.current.path
    end

    get '/articles/:id' do
      @article = Article.open("articles/#{params[:id]}")
      if @article
        @previous_article, @next_article = @article.previous, @article.next

        haml :show
      else
        haml :not_found
      end
    end
    
    get '/drafts' do
      @articles = Article.drafts
      
      haml :drafts
    end

    get '/rss.xml' do
      @articles = Article.all

      builder do |xml|
        xml.instruct! :xml, :version => '1.0'
        xml.rss :version => "2.0" do
          xml.channel do
            xml.title "Jason Cale :: Young Delta Heart"
            xml.description "Ruby developer :: UI Designer"
            xml.link "http://jasoncale.com/"

            @articles.each do |article|
              xml.item do
                xml.title article.title
                xml.link "http://jasoncale.com/articles/#{article.permalink}"
                xml.description article.body
                xml.pubDate Time.parse(article.post_date.to_s).rfc822()
                xml.guid "http://jasoncale.com/articles/#{article.permalink}"
              end
            end
          end
        end
      end
    end

  end
end