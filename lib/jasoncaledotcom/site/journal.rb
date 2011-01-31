require 'tumblr'

module Jasoncaledotcom
  class Site
    class Journal
      class << self
        def recent(tumblr_email, tumblr_password, tumblr_blog, opts = {})
          opts = {:num => 10, :start => 0}.merge(opts)
          response = Tumblr::Reader.new(tumblr_email, tumblr_password).authenticated_read(tumblr_blog, opts).perform
          if response.success?
            posts = Tumblr::Reader.get_posts(response)
          else
            return false
          end
        end
      end
    end
  end
end