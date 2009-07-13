:meta:title: I just wanna be your firecracker
:meta:date: Mon Jul 13 22:00:33 +0100 2009

Tonight I've added a few extras to the site, and fixed a few bugs that had crept in from the first iteration - those I had noticed are as follows:

* **Article post date** - I was originally using the "created at" date on each of my article files (basically I have a directory called 'articles' which holds individual _article-name.markdown_ files, which are parsed into ruby objects). This was fine locally, but when I was deploying (very obviously) the files were getting created locally on the server as they were pushed with the git commit. With each deployment all the articles would be updated with the current date.
* **Titles with lots of punctuation** - The way I first setup the articles was to parse the title from the article file. The problem with this is that any punctuation in the filenames will mess up the file manipulation.

#### Article dates &amp; titles
These were fairly trivial, I've added a manifest to each article file [(see the source for this article)](http://github.com/jasoncale/jasoncaledotcom/raw/26029a026d422e5d51c51c34a878ee547b86ab70/articles/2-i-just-wanna-be-your-firecracker.markdown) - and a [simple rake task](http://github.com/jasoncale/jasoncaledotcom/blob/d00c802662757b873f47564284b7a744bb766b73/Rakefile) to generate articles, so I don't have to fill this in by hand when creating new articles. When I parse the files I set the article object's title and post_date attributes from the meta data, then I remove it from the body so the rest of the file can be rendered as markdown.

Cool I thought .. so I added a few extra bits while I was at it.

#### RSS Feed
I've also added a quick RSS feed for the site, if you like that kinda thing .. 

#### Twitter Integration
Someone (i thought it was [Cole Henley](http://twitter.com/cole007) but I can't find the tweet) posted a link on twitter today to a nice little 'repost' link made by jQuery creator John Resig. It's dead simple to pop in (I just did it while typing this), and is pretty cool .. check out his [blog post here](http://ejohn.org/blog/retweet/), and you will see the 'retweet' link below this article. Pretty cool - although I probably could do with tweaking the whitespace it seems to create..
