$(document).ready(function() {
  AudioPlayer.setup("http://jasoncale.com/player.swf", { width: 290 });

  $('input.music').each(function (i) {
    AudioPlayer.embed(("audioplayer_" + i), {soundFile: "http://jasoncaleassets.s3-external-3.amazonaws.com/"+$(this).attr('value')}); 
  });

});
