run lambda { |env| 
  week = DateTime.now.strftime("%V")
  body = File.read('index.html').gsub(/\[CURRENT_WEEK\]/, week)
  [
    200, {
            'Content-Type'=>'text/html', 
            'Content-Length' => body.length.to_s, 
            'Cache-Control' => 'public, max-age=3600'
    }, body
  ] 
}
