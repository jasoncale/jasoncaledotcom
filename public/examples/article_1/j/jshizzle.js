var app = (function($) {
  
  var createLink = function (el, linkText, classNames, append) {
    
    if (!linkText) linkText = '';
    if (!classNames) classNames = ''; 
    
    var link = '<a href="#" class="'+ classNames +'">'+ linkText +'</a>';
    
    if (append) {
      el.append(link);
      return el.find('a:last-child');
    } else {
      el.wrap(link);
      return el.parent();
    }
  }
  
  function getSisterInput(element) {
    return $(element).siblings('input:radio, input:checkbox');
  }
  
  $.fn.extend({

    enableLabelToggle: function(action_callback) {
      createLink($(this), "", "action").click(function () {
        
        // grab related input element ..
        var input = getSisterInput($(this));
                
        // is the input checked?
        var selected = !input.attr('checked');
        
        // we can add some behavioural rules here...
        var canChange = true;
        
        // make sure we don't uncheck any radio buttons that are selected
        if (input.attr('type') == "radio" && input.attr('checked')) canChange = false;
        
        if (canChange) {
          // toggle the link's class name depending on input state
          $(this).toggleClass('selected', selected);
                
          // toggle the input box
          input.attr('checked', selected);
        
          // if the input element is a radio button
          // we need to tell the other radio elements
          // within the group that they have changed
          // so they can update their associated links        
          if (input.attr('type') == "radio") {
            // find any inputs that have the same name,
            // as they will be part of the same group
            // and call change() as defined in the "each"
            // function below
            $('input[name="'+input.attr('name')+'"]').change();
          };
        };
        
        action_callback.apply($(this));

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
        }).change();
        
        // I have appended a change() on the end of the change() definition
        // to catch any initial states set on the form ..
        
      });
      
      return $(this);
    }

  });
  
  return {
    createLink: createLink
  }
  
})(jQuery);
      
(function ($) {
  
  var employeeManagerCallback = function () {
    console.log("FIRE AJAX FOR MANAGER!");
  }
  
  var employeeAssistantCallback = function () {
    console.log("FIRE AJAX FOR ASSISTANT!");
  }
  
  var employeeRemoveCallback = function () {
    $(this).parents().filter('.employee').fadeOut();
  }
  
  $.fn.extend({
    employeeWidget: function () {
      
      $(this).addClass('js');
      
      app.createLink($(this).find('.employee'), "options", "toggle_options", true).click(function () {
        
        var link = $(this);
        
        $(this).siblings('.employee_options').slideToggle('slow', function () {          
          link.toggleClass('selected', ($(this).css('display') == "block"));
        });
        
        link.toggleClass('selected', true);
        
      }).siblings('.employee_options').hide();
    
      $(this).find('.employee_options li.manager label').enableLabelToggle(employeeManagerCallback);
      $(this).find('.employee_options li.assistant label').enableLabelToggle(employeeAssistantCallback);
      $(this).find('.employee_options li.remove label').enableLabelToggle(employeeRemoveCallback);
  
    }
  
  });
  
})(jQuery);