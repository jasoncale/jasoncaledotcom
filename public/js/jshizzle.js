$(document).ready(function() {
  // AudioPlayer.setup("http://jasoncale.com/player.swf", { width: 400 });

  // $("a[href$='.mp3']").each(function (i) {
  //   $(this).attr("id", "audioplayer_" + i);
  //   
  //   AudioPlayer.embed($(this).attr("id"), {soundFile: $(this).attr('href')}); 
  // });

  $('code.eval').click(function () {
    eval($(this).html());
  })
  
  $("body.face").css({    
    "background-image": "url(http://farm5.static.flickr.com/4104/5055771352_319d1f4e98_o.jpg)",
    "background-repeat": "no-repeat",
    "background-size": "cover"
  });
  
  
  // $.getJSON("http://api.flickr.com/services/feeds/groups_pool .gne?id=675729@N22&lang=en-us&format=json&jsoncallback=?", function(data){
  //     $.each(data.items, function(i,item){
  //       $("<img/>").attr("src", item.media.m).appendTo("#images")
  //         .wrap("<a href='" + item.link + "'></a>");
  //     });
  //   

});
