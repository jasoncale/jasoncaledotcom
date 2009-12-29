require 'active_support/core_ext/date'
require 'active_support/inflector' 
require 'rdiscount'
require 'net/http'
require 'uri'
require 'httparty'

module Jasoncaledotcom
  
  class Article

    attr_accessor :title, :body, :post_date, :permalink, :meta

    def initialize(body, meta, permalink)
      @title = meta[:title]
      @body = Haml::Engine.new(body).render
      @post_date = meta[:date]
      @meta = meta[:meta]
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
      (article_files(reset).map { |filename| Article.open(filename) }).select {|article| article }.reverse
    end

    def self.open(filename)
      article = false
      
      filename << ".yml" if !(filename =~ /.yml/)
      
      if File.exist?(filename)
        data = YAML.load_file(filename)
        permalink = to_permalink(remove_ext(File.basename(filename)))
        
        article = Article.new(data[:content], data, permalink)
      end
      
      article
    end
    
    def self.remove_ext(name)
      name.gsub(/.yml/, '')
    end
    
    def self.add_ext(name)
      name << ".yml" if !(name =~ /.yml/)
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
      meta = {}
      body = []
      
      lines.each do |line|
        if line.match(/:meta:([a-z]+):(.+)/)
          key, val = $1.to_sym, $2
          val = Date.parse(val) if key.eql?(:date)
          meta[key] = val
        else
          body << line
        end
      end
      
      return body.join(""), meta
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
          tracks = []
          _get("user.getrecenttracks")['lfm']['recenttracks']['track'].each do |track|  
            # get medium
            image_url = (track['image'][1] =~ /http/) ? track['image'][1] : ""
            tracks << Track.new(track['artist'], track['name'], image_url, track['url'])
          end
          tracks
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
      
      def is_up?
        url = URI.parse("http://twitter.com/statuses/public_timeline.json")

        http = Net::HTTP.new(url.host, url.port)
        http.read_timeout = 3
        http.open_timeout = 3
        
        begin
          resp = http.start() {|http|
            http.get(url.path)
          }
          
          return (resp.code =~ /2|3\d{2}/)
          
        rescue (Timeout::Error||Errno::ECONNRESET) => e
          return false
        end

      end
      
      def latest
        if (is_up?)
          #find latest tweet that doesnt have a @ in it ..
          tweet = get("/statuses/user_timeline.json", :timeout => 100).select {|tweet| (tweet['text'] !~ /^@/) }.first
          tweet = Tweet.new(tweet['id'], tweet['text'], tweet['created_at']) if tweet
        else
          false
        end
      end
    end
  end
  
end
