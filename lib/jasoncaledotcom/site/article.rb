require 'rdiscount'
require 'yaml'
require "haml"

module Jasoncaledotcom
  class Site
    class Article
      attr_accessor :title, :body, :post_date, :permalink, :published

      def initialize(body, meta, permalink)
        @title = meta[:title]
        @body = Haml::Engine.new(body).render
        @post_date = Time.parse(meta[:date]).getlocal
        @permalink = permalink
        @published = meta[:published]
      end
      #
      # def previous
      #   Article.open_by_id(id - 1)
      # end
      #
      # def id
      #   permalink.match(/(\d+).*/)[1].to_i
      # end
      #
      # def next
      #   Article.open_by_id(id + 1)
      # end
      #
      #
      def published?
        published.eql?(true)
      end
      #
      # def path
      #   "#{Article::article_dir}/#{permalink}"
      # end

      class << self
        attr_accessor :article_dir

        # def count(reset = false)
        #   article_files(reset).size
        # end
        #

        def all(reset = false)
          article_files(reset).map { |filename| Article.open(filename) }.compact
        end

        def published(reset = false)
          all(reset).select {|article| article.published? }.sort_by(&:post_date).reverse
        end

        # def drafts(reset = true)
        #   (article_files(reset).map { |filename| Article.open(filename) }).select {|article| article && !article.published }.reverse
        # end
        #
        # def current(reset = false, published = true)
        #   published(reset, published).first
        # end
        #
        # def open_by_id(id)
        #   if match = Dir.glob("#{article_dir}/#{id}*")
        #     Article.open(match.first) unless match.empty?
        #   end
        # end

        def open(filename)
          article = nil

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
      #
      #   def add_ext(name)
      #     name << ".yml" if !(name =~ /.yml/)
      #     name
      #   end
      #
      #   def parse_title(name)
      #     remove_ext(name).gsub(/\d-/, '').gsub(/-/, '_').humanize
      #   end
      #
        def to_permalink(string)
          string.gsub(/[^\w\s\-]/,'').gsub(/[^\w]|[\_]/,' ').split.join('-').downcase
        end
      #
      #   def build_filename(title)
      #     add_ext(to_permalink("#{count+1}-#{title}"))
      #   end
      #
      #   def path(name)
      #     File.join(article_dir, add_ext(name))
      #   end
      #
      #
      #     return body.join(""), meta
      #   end
      #
        def article_files(reset = false)
          @article_files = nil if reset
          @article_files ||= (Dir.glob(File.join('**', article_dir, "*")))
        end
      end

      self.article_dir = "articles"

    end
  end
end