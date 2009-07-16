$(document).ready(function() {
  AudioPlayer.setup("http://jasoncale.com/player.swf", { width: 400 });

  $('input.music').each(function (i) {
    $(this).after('<p id="audioplayer_'+i+'">Music here</p>');
    AudioPlayer.embed(("audioplayer_" + i), {soundFile: "http://jasoncaleassets.s3-external-3.amazonaws.com/"+$(this).attr('value')}); 
  });

});
