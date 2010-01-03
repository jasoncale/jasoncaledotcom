$(document).ready(function() {
  AudioPlayer.setup("http://jasoncale.com/player.swf", { width: 400 });

  $("a[href$='.mp3']").each(function (i) {
    $(this).attr("id", "audioplayer_" + i);
    
    AudioPlayer.embed($(this).attr("id"), {soundFile: $(this).attr('href')}); 
  });

  $('code.eval').click(function () {
    eval($(this).html());
  })

});
