(function($) {
  
  $.fn.extend({
    
    createLink: function (linkText, classNames, append) {
      
      if (!linkText) linkText = '';
      if (!classNames) classNames = ''; 
      
      var link = '<a href="#" class="'+ classNames +'">'+ linkText +'</a>';
      
      if (append) {
        $(this).append(link);
        return $(this).find('a:last-child');
      } else {
        $(this).wrap(link);
        return $(this).parent();
      }

    },
    
    enableLabelToggle: function() {
      $(this).createLink("", "action").click(function () {
        //find the input related to label
        var input = $(this).siblings('input:radio, input:checkbox');
        
        // is the input checked?
        var selected = !input.attr('checked');

        // toggle the link's class name depending on input state
        $(this).toggleClass('selected', selected);
                
        // toggle the input box
        input.attr('checked', selected);
        
        return false;
      }).each(function () {
        
        // we also want to catch any change
        // events on the input elements this
        // link controls, so we can update
        // the link state if the input changes
        // by another event that this link's 
        // click event
        
        // grab a reference to link for closure
        var link = $(this);
                
        // find inputs to bind change event on, then hide them
        $(this).siblings('input:radio, input:checkbox').hide().change(function (){
          
          // toggle the link's class name depending on input state
          link.toggleClass('selected', $(this).attr('checked'));
        });
      });
      
      return $(this);
    }

  })
  
})(jQuery);
      
(function ($) {
  
  $.fn.extend({
    employeeWidget: function () {
    
      $(this).find('.employee').createLink("options", "toggle_options", true).click(function () {
        
        var link = $(this);
        
        $(this).siblings('.employee_options').slideToggle('slow', function () {          
          link.toggleClass('selected', ($(this).css('display') == "block"));
        });
        
        link.toggleClass('selected', true);
        
      }).siblings('.employee_options').hide();
    
      $(this).find('.employee_options li label').enableLabelToggle();
    }
  });
  
})(jQuery);