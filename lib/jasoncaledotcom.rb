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

    def self.count(reset = false)
      article_files(reset).size
    end
    
    def self.all(reset = false)
      # remove any falses ..
      (article_files(reset).map { |filename| Article.open(filename) }).select {|article| article }
    end

    def self.open(filename)
      article = false
      
      filename << ".markdown" if !(filename =~ /.markdown/)
      
      if File.exist?(filename)
        File.open(filename) do |f|
          title, date, body = parse_data(f.readlines)
          permalink = to_permalink(remove_ext(File.basename(filename)))
                    
          article = Article.new(title, body, date, permalink)
        end
      end
      
      article
    end
    
    def self.remove_ext(name)
      name.gsub(/.markdown/, '')
    end
    
    def self.add_ext(name)
      name << ".markdown" if !(name =~ /.markdown/)
      name
    end

    def self.parse_title(name)
      remove_ext(name).gsub(/\d-/, '').gsub(/-/, '_').humanize
    end

    def self.to_permalink(string)
      string.gsub(/[^\w\s\-\â€”]/,'').gsub(/[^\w]|[\_]/,' ').split.join('-').downcase  
    end
    
    def self.build_filename(title)
      add_ext(to_permalink("#{count+1}-#{title}"))
    end
    
    def self.path(name)
      File.join(article_dir, add_ext(name))
    end
    
    def self.parse_data(lines)
      title, date, body = "", "", []
      
      lines.each do |line|
        if line =~ /^:meta/
          title = line.gsub(/:meta:title:\s/, '') if line =~ /:meta:title:/
          date = Date.parse(line.gsub(/:meta:date:\s/, '')) if line =~ /:meta:date:/
        else
          body << line
        end
      end
      
      return title, date, body.join("")
    end
    
    def self.article_files(reset = false)
      @article_files = nil if reset

      @article_files ||= (Dir.glob(File.join('**', "articles", "*")))
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
  
  class Flickr

  end
  
  class Tweet
    include HTTParty
    base_uri 'twitter.com'
    basic_auth ENV['TWITTER_USER'], ENV['TWITTER_PASS']
    format :json
    
    attr_accessor :id, :text, :created_at
    
    def initialize(id, text, created_at)
      @id = id
      @text = text
      @created_at = Time.parse(created_at)
    end
    
    class << self
      def latest
        @latest ||= (
          #find latest tweet that doesnt have a @ in it ..
          tweet = get("/statuses/user_timeline.json").select {|tweet| (tweet['text'] !~ /^@/) }.first
          tweet = Tweet.new(tweet['id'], tweet['text'], tweet['created_at']) if tweet
        )
      end
    end
  end
  
end