require 'sinatra/base'

module Jase
  module HelpMeOut
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def link(text, link, title = nil)
      title = "visit link: #{text}" if title.blank?
      "<a href ='#{link}' title='#{title}'>#{text}</a>"
    end
  
    def tweet_link(tweet)
      link tweet.text, tweet_url(tweet.id), "go to twitter"
    end
    
    def tweet_url(id)
      "http://twitter.com/#{ENV['TWITTER_USER']}/status/#{id}"
    end
    
    def distance_of_time_in_words(from_time, to_time)
      distance_in_minutes = ((to_time - from_time) / 60).round

      case distance_in_minutes
        when 0          then "less than a minute"
        when 1          then "1 minute"
        when 2..45      then "#{distance_in_minutes} minutes"
        when 46..90     then "about 1 hour"
        when 90..1440   then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1441..2880 then "1 day"
        else                 "#{(distance_in_minutes / 1440).round} days"
      end
    end

    def distance_of_time_in_words_to_now(from_time)
      if !from_time.is_a?(Time)
        from_time = Time.parse(from_time)
      end
      distance_of_time_in_words(from_time, Time.now)
    end
    
    def code_sample(title, file, range = nil)
      lines = File.readlines(File.join('public', 'examples', file))
      
      haml_tag(:div, :class => 'code_sample') do
        
        haml_tag(:h3) do
          haml_concat title
          haml_concat link("(download source)", "/examples/#{file}", "Download code")
        end
        
        range = (0..lines.length) if range.nil? || !range.respond_to?(:min)
        
        haml_tag(:ol, { :class => 'code', :start => (range.min + 1) })  do 
          
          lines[range].each do |line|
            haml_tag(:li) do
              code_class = line.match(/(\s+)(.+)/) ? "tab_#{($1.length / 2)}" : ""
              
              if File.extname(file).match(/rb|js/) 
                code_class << " comment" if line.match(/^\s*(#|\/{2})/)
              end
              
              haml_tag(:code, {:class => code_class }) do
                haml_concat h(line)
              end
            end
          end

        end
      
      end
      
    end
    
  end
end

module Sinatra
  helpers Jase::HelpMeOut
end