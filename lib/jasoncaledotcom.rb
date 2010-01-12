# require 'active_support/core_ext/date'
# require 'active_support/inflector' 
require 'rdiscount'
require 'net/http'
require 'uri'
require 'httparty'


require File.join(File.dirname(__FILE__), 'help_me_out')


module Haml
  module Helpers
    include Jase::HelpMeOut
  end
end

module Jasoncaledotcom
  
  class Article

    attr_accessor :title, :body, :post_date, :permalink, :meta, :published

    def initialize(body, meta, permalink)
      @title = meta[:title]
      @body = Haml::Engine.new(body).render
      @post_date = meta[:date]
      @meta = meta[:meta]
      @permalink = permalink
      @published = meta[:published]
    end
    
    def previous
      Article.open_by_id(id - 1)
    end
    
    def id
      permalink.match(/(\d+).*/)[1].to_i
    end
    
    def next
      Article.open_by_id(id + 1)
    end
    
    
    def published?
      published.eql?(true)
    end
    
    def path
      "#{Article::article_dir}/#{permalink}"
    end
    
    class << self
      attr_accessor :article_dir
      
      def count(reset = false)
        article_files(reset).size
      end

      def all(reset = false, published = true)
        published(reset, published)
      end
      
      def published(reset = false, published = true)
        (article_files(reset).map { |filename| Article.open(filename) }).select {|article| article && (article.published == published) }.reverse
      end
      
      def current(reset = false, published = true)
        published(reset, published).first
      end
      
      def open_by_id(id)
        if match = Dir.glob("#{article_dir}/#{id}*")
          Article.open(match.first) unless match.empty?
        end
      end

      def open(filename)
        article = false

        filename << ".yml" if !(filename =~ /.yml/)

        if File.exist?(filename)
          data = YAML.load_file(filename)
          permalink = to_permalink(remove_ext(File.basename(filename)))

          article = Article.new(data[:content], data, permalink)
        end

        article
      end

      def remove_ext(name)
        name.gsub(/.yml/, '')
      end

      def add_ext(name)
        name << ".yml" if !(name =~ /.yml/)
        name
      end

      def parse_title(name)
        remove_ext(name).gsub(/\d-/, '').gsub(/-/, '_').humanize
      end

      def to_permalink(string)
        string.gsub(/[^\w\s\-\â€”]/,'').gsub(/[^\w]|[\_]/,' ').split.join('-').downcase  
      end

      def build_filename(title)
        add_ext(to_permalink("#{count+1}-#{title}"))
      end

      def path(name)
        File.join(article_dir, add_ext(name))
      end

      def parse_data(lines)
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

      def article_files(reset = false)
        @article_files = nil if reset

        @article_files ||= (Dir.glob(File.join('**', "articles", "*")))
      end
    
    end
    
    self.article_dir = "articles"

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
