require 'net/http'
require 'uri'
require 'httparty'

module Jasoncaledotcom
  class Site
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
  end
end