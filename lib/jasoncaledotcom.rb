module Jasoncaledotcom
  require 'grit'

  class GitStore
    include Grit

    class << self
      attr_accessor :git_repo 
    end

    self.git_repo = Repo.new(".git")

    def self.commits
      git_repo.commits
    end

  end

  class Article

    attr_accessor :body, :post_date, :permalink

    def initialize(body, date, permalink)
      @body = body
      @post_date = date
    end

    def render
      haml_engine = Haml::Engine.new(@body).render
    end

    def self.all
      articles = []

      GitStore.commits.each do |commit|
        commit.tree.contents.each do |article|
          articles << Article.new(
            article.data,
            commit.authored_date,
            create_permalink(article.name)
          )
        end
      end

      return articles
    end

    def self.create_permalink(name)
      name.gsub(/.haml/, '')
    end

  end
end