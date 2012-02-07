require 'test_helper'
require "jasoncaledotcom/site/article"

class ArticleTest < Test::Unit::TestCase

  context "opening published article file" do
    setup do
      @article = Jasoncaledotcom::Site::Article.open('fixtures/1-an-article.yml')
    end

    should "parse title of the article" do
      assert_equal("The fine art of degradable interface elements", @article.title)
    end

    should "parse the body into html" do
      assert_match /<h2>This is the title<\/h2>/, @article.body
      assert_match /<p>This is some body content<\/p>/, @article.body
    end

    should "parse the article date" do
      assert_equal(Time.new(2012,2,7,18,03,18).getlocal, @article.post_date)
    end

    should "parse the permalink" do
      assert_equal("1-an-article", @article.permalink)
    end

    should "parse whether the article is published or not" do
      assert_equal(true, @article.published)
    end

    should "be published" do
      assert(@article.published?)
    end
  end

  context "opening draft article file" do
    setup do
      @article = Jasoncaledotcom::Site::Article.open('fixtures/draft-article.yml')
    end

    should "parse whether that the article a draft" do
      assert_equal(false, @article.published)
    end

    should "not be published" do
      refute(@article.published?)
    end
  end

  context "Published articles" do
    setup do
      Jasoncaledotcom::Site::Article.article_dir = 'fixtures'
      @articles = Jasoncaledotcom::Site::Article.published
    end

    should "return all published articles" do
      assert_equal(2, @articles.length)
    end

    should "return the latest article first" do
      assert_equal('another-published-article', @articles.first.permalink)
    end
  end

end