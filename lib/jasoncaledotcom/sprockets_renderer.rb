module Jasoncaledotcom
  module SprocketsRenderer
    def render_sprockets
      # if we are in development mode, or the file doesn't exist in any other env
      # we should generate the sprockets file that we will serve in the next step
      generate_sprockets if development? || !File.exists?(sprockets_file)
      
      # set the content type and serve the file
      content_type 'text/javascript', :charset => 'utf-8'
      File.read(sprockets_file)
    end
    
    private
    
    def generate_sprockets
      Sprockets::Secretary.new(sprockets_options).concatenation.save_to(sprockets_file)
    end
  
    def sprockets_file
      File.join('public', 'js', 'sprockets.js')
    end
  
    def sprockets_options(options = {})
      options.merge(
        :load_path => [ "public/js"],
        :source_files => ["public/js/include/*.js", "public/js/jshizzle.js"]
      )
    end
  end
end