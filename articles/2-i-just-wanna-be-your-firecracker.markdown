:meta:title: I just wanna be your firecracker
:meta:date: Mon Jul 13 22:00:33 +0100 2009

Tonight I've added a few extras to the site, and fixed a few bugs that had crept in from the first iteration - those I had noticed are as follows:

* **Article post date** - I was originally using the created at date on each of my article files when creating an Article object to display. This was fine locally, but when I was deploying (very obviously) the files were getting created as they were pushed with the git commit. With each deployment all the articles would be updated with the current date.
* **Titles with lots of punctuation** - The way I first setup the articles was to parse the title from the article file (basically I have a directory called 'articles' which holds individual _article-name.markdown_ files, which are parsed into ruby objects). The problem with this is that any punctuation in the filenames will mess up the file manipulation.
* **Caching** - for some reason the cache isn't being purged by Heroku, I'm using their [http caching](http://docs.heroku.com/http-caching "Heroku Documentation: HTTP Caching") using Varnish - you can see the code I've used [here](http://github.com/jasoncale/jasoncaledotcom/blob/be462fa6740b32cef4a87bf41f44cc2ccffe513c/jasoncaledotcom.rb) (around line 30).

#### Article dates &amp; titles
These were fairly trivial, I've added a manifest to each article file (see the source for this article) - and a simple rake task to generate articles, so I don't have to fill this in by hand when creating now articles.