$(document).ready(function() {
  AudioPlayer.setup("http://jasoncale.com/player.swf", { width: 290 });

  $('input.music').each(function (i) {
    AudioPlayer.embed(("audioplayer_" + i), {soundFile: "http://jasoncale.com/tunes/"+$(this).attr('value')}); 
  });

});
