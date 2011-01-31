require "rubygems"
require "bundler"
Bundler.setup

$LOAD_PATH << File.dirname(__FILE__) + "/lib"

require 'tumblr'

r = Tumblr::Reader.new("jason.cale@me.com", "AULjm}K9a.Zs6eqbhd")

response = r.authenticated_read("jasoncale", {:num => 10, :start => 0}).perform

posts = Tumblr::Reader.get_posts(response)

p posts.first.type