module Jasoncaledotcom
  module Helpers
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def link(text, link, title = nil)
      title = "visit link: #{text}" if title.nil?
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
    
    def code_block(lines)
      haml_tag(:p, :class => "code_block") do
        lines.each do |line|        
          haml_tag(:code) do
            haml_concat h(line)
          end
        end
      end
    end
    
    def irb_session(file, options = {})
      lines = read_example(file)
      options = {:range => (0..lines.length), :class => 'code_sample'}.merge!(options)
      haml_tag(:div, :class => options[:class]) do
        code_list(lines, file, options)
      end
    end
    
    def read_example(filename)
      File.readlines(File.join('public', 'examples', filename))
    end
    
    def code_sample(title, file, options = {})
      lines = read_example(file)
      options = {:range => (0..lines.length), :download_link => "Download code", :class => 'code_sample'}.merge!(options)
      haml_tag(:div, :class => options[:class]) do
        haml_tag(:h3) do
          haml_concat title
          haml_concat link("(download source)", "/examples/#{file}", options[:download_link])
        end
        code_list(lines, file, options)
      end
    end
    
    def code_list(lines, file, options = {})
      haml_tag(:ol, { :class => 'code', :start => (options[:range].min + 1) })  do 
        lines[options[:range]].each do |line|
          haml_tag(:li) do
            code_class = line.match(/(\s+)(.+)/) ? "tab_#{($1.length / 2)}" : ""
            if File.extname(file).match(/rb|js/) 
              code_class << " comment" if line.match(/^\s*(#|\/{2})/)
            end
            code_class << " command" if line.match(/^\s*(>>)/)
            code_class << " result" if line.match(/^\s*(=>)/)
            haml_tag(:code, {:class => code_class }) do
              haml_concat h(line)
            end
          end
        end
      end
    end
    
    def age(dob = nil)
      now = Time.now.utc
      dob ||= Time.utc(1983, 7, 27)
      now.year - dob.year - ((now < Time.utc(now.year, dob.month, dob.day) ? 1 : 0))
    end
    
    def ordinalize(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}th"
      else
        case number.to_i % 10
          when 1; "#{number}st"
          when 2; "#{number}nd"
          when 3; "#{number}rd"
          else    "#{number}th"
        end
      end
    end
    
    def journal_entry(entry)
      haml_tag(:div, :class => entry.type) do
        case entry.type
        when :video
          haml_concat entry.embed
          haml_concat entry.caption
        when :quote
          haml_tag :blockquote, entry.quote
          haml_tag (:p, :class => "source") do
            haml_concat entry.source
          end
        when :photo
          haml_tag(:a, :href => entry.click_through_url) do
            haml_tag(:img, :src => entry.source)
          end
          haml_concat entry.caption
        else
          haml_tag(:h3) do
            haml_concat "Don't know"
          end
        end
      end
    end
    
  end
end

module Haml::Helpers
  include Jasoncaledotcom::Helpers
end
