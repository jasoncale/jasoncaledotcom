require 'active_support/core_ext/date'
require 'active_support/inflector' 
require 'rdiscount'
require 'httparty'

module Jasoncaledotcom

  class Article

    attr_accessor :title, :body, :post_date, :permalink

    def initialize(title, body, date, permalink)
      @title = title
      @body = RDiscount.new(body).to_html
      @post_date = date
      @permalink = permalink
    end
    
    class << self
      attr_accessor :article_dir
    end
    
    self.article_dir = "articles"

    
    def self.all
      articles = (Dir.glob(File.join('**', "articles", "*")).map { |filename| Article.open(filename) })
      
      # remove any falses ..
      articles.select {|article| article }
    end

    def self.open(filename)
      article = false
      
      if File.exist?(filename)
        File.open(filename) do |f|
          article_name = File.basename(filename)
          article = Article.new(parse_title(article_name), f.readlines.join(""), f.ctime, filename)
        end
      end
      
      article
    end
    
    def self.remove_ext(name)
      name.gsub(/.haml/, '')
    end

    def self.parse_title(name)
      remove_ext(name).gsub(/\d-/, '').gsub(/-/, '_').humanize
    end

  end


  module LastFm
    
    class Base
      include HTTParty
  
      base_uri 'http://ws.audioscrobbler.com/2.0/'
  
      # LAST FM user and key are set using Heroku config settings
      # http://blog.heroku.com/archives/2009/4/7/config-vars/
  
      default_params :user => ENV["LASTFM_USER"], :api_key => ENV['LASTFM_KEY'], :limit => 12
      format :xml
      
      def self._get(method)
        get('', :query => {:method => method})
      end
      
    end

    class Track < Base
      
      attr_reader :artist, :name, :image, :url
      
      def initialize(artist, name, image, url)
        @artist = artist
        @name = name
        @image = image
        @url = url
      end

      class << self
        def recent
          @recent_tracks ||= (
            tracks = []
            _get("user.getrecenttracks")['lfm']['recenttracks']['track'].each do |track|  
              # get medium
              image_url = (track['image'][1] =~ /http/) ? track['image'][1] : ""
            
              tracks << Track.new(track['artist'], track['name'], image_url, track['url'])
            end
            tracks
          )
        end
      end

    end

  end
  
end