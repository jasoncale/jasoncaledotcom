require 'net/http'
require 'uri'
require 'httparty'

module Jasoncaledotcom
  class Site
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
end