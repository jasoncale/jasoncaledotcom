require 'active_support/core_ext/date'
require 'active_support/inflector' 
require 'grit'
require 'rdiscount'

module Jasoncaledotcom

  class GitStore
    include Grit

    class << self
      attr_accessor :repo 
    end

    self.repo = Repo.new(File.expand_path(".git"))

    def self.commits
      repo.commits
    end
    
    def self.master
      repo.commits.first.tree
    end
    
    def self.get(name)
      (master / name)
    end
    
    def self.log(path)
      repo.log('master', path)
    end
    
  end

  class Article

    attr_accessor :title, :body, :post_date, :permalink

    def initialize(title, body, date, permalink)
      @title = title
      @body = RDiscount.new(body).to_html
      @post_date = date
      @permalink = permalink
    end

    def self.all
      articles = []
      
      GitStore.get("articles").contents.each do |article|
        articles << Article.new(
          parse_title(article.name),
          article.data,
          info(article.name).authored_date,
          remove_ext(article.name)
        )
      end

      return articles.reverse
    end
    
    def self.info(name)
      GitStore.log("articles/#{name}").first
    end

    def self.remove_ext(name)
      name.gsub(/.haml/, '')
    end

    def self.parse_title(name)
      remove_ext(name).gsub(/\d-/, '').gsub(/-/, '_').humanize
    end

  end
end