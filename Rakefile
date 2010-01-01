require 'jasoncaledotcom'

namespace :jc do
  
  desc "Create an article"
  task :article, :title do |task, args|
    if args.title.blank?
      puts "Title can't be blank"
    else    
      article_name = Article.build_filename(args.title)
      File.open(Article.path(article_name), "w") do |f|
        f << ":title: | #{args.title}\n"
        f << ":date: #{Time.now.to_s}\n"
        f << ":meta:\n  :some_attribute: value\n"
        f << ":content: |\n\n  %h2 Start writing article here.."    
      end
    end
  end
  
end