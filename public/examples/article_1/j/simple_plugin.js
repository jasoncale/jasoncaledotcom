$.fn.hideMe = function () {
  $(this).click(function () { 
    alert("I'm off, see you later!");
    $(this).fadeOut();
  });
}

$(document).ready(function () {
  $('a.hide_me').hideMe();
});