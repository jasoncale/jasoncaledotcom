require 'active_support/core_ext/date'
require 'active_support/inflector' 
require 'rdiscount'
module Jasoncaledotcom

  class Article

    attr_accessor :title, :body, :post_date, :permalink

    def initialize(title, body, date, permalink)
      @title = title
      @body = RDiscount.new(body).to_html
      @post_date = date
      @permalink = permalink
    end
    
    class << self
      attr_accessor :article_dir
    end
    
    self.article_dir = "articles"

    
    def self.all
      articles = (Dir.glob(File.join('**', "articles", "*")).map { |filename| Article.open(filename) })
      
      # remove any falses ..
      articles.select {|article| article }
    end

    def self.open(filename)
      article = false
      
      if File.exist?(filename)
        File.open(filename) do |f|
          article_name = File.basename(filename)
          article = Article.new(parse_title(article_name), f.readlines.join(""), f.ctime, filename)
        end
      end
      
      article
    end
    
    def self.remove_ext(name)
      name.gsub(/.haml/, '')
    end

    def self.parse_title(name)
      remove_ext(name).gsub(/\d-/, '').gsub(/-/, '_').humanize
    end

  end
  
end