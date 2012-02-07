require "rubygems"
require "bundler"
Bundler.setup

$LOAD_PATH << File.dirname(__FILE__) + "/lib"

require 'jasoncaledotcom'

namespace :jc do

  desc "Create an article"
  task :article, :title do |task, args|
    if args.title.nil?
      puts "Title can't be blank"
    else
      article_name = Jasoncaledotcom::Site::Article.build_filename(args.title)
      File.open(Jasoncaledotcom::Site::Article.path(article_name), "w") do |f|
        f << ":title: | #{args.title}\n"
        f << ":date: #{Time.now.getlocal.to_s}\n"
        f << ":content: |\n\n  %h2 Start writing article here.."
      end
    end
  end

end