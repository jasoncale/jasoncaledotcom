require 'rdiscount'

module Jasoncaledotcom
  class Site
    class Article
      helpers Jasoncaledotcom::Helpers
      
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
  end
end