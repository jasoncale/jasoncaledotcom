require 'sinatra/base'

module Sinatra
  module HelpMeOut
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def link(text, link, title)
      "<a href ='#{link}' title='#{title}'>#{text}</a>"
    end
  end
  
  helpers HelpMeOut
end