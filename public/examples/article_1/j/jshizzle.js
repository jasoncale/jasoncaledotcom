var app = (function($) {
    
  // createLink() is a utility to wrap or append an element
  // with a link .. usually to add behaviour to a bit of markup.
  // 
  // it will return a jQuery reference to the newly created element
  // so it can be chained or have events bound to it.
  // 
  // createLink($('span')).click(function () { $(this).hide() });
  // 
  // passing in linkText, classNames will put those onto the link
  // 
  // and passing a boolean to append will append the link to the 
  // element passed into the function instead of wrapping it.
  // 
  // NOTE: I'm saving a reference to createLink so I can return
  // it outside of the wrapper, and use it elsewhere in the 
  // application, whilst encapsulating its magic.
  
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
        
        // grab related input element .. using our lovely
        // little utility method.
        var input = getSisterInput($(this));
                
        // is the input checked? - (try it in the console)
        var selected = !input.attr('checked');
        
        // now we add some behavioural rules ...
        var canChange = true;
        
        // make sure we don't uncheck any radio buttons that are selected
        if (input.attr('type') == "radio" && input.attr('checked')) canChange = false;
        
        // we add more later, lets stay agile and all that ..
        
        // if all our rules passed, we are good to make the change.
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
        
        // call the function passed into enableLabelToggle
        // using apply to make any references to 'this'
        // inside the callback function point to this link.
        action_callback.apply($(this));

        // return false, so it doesn't do anything else.
        return false;
        
        //next we loop through each matching label, and apply the following:
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
      
      // return $(this) so we can chain the method should we wish.
      return $(this);
    }

  });
  
  // return our helper method so it can be used outside of this closure.
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
  
  // Here I'm using $.fn.extend to add my functions to the jQuery
  // api, this is just a different way to defining a plugin action
  // but has the same effect of doing
  //  
  // $.fn.employWidget = function () {}
  //
  
  $.fn.extend({
    employeeWidget: function () {
      // add the js class to the element, so we can
      // do specific css to javascript users
      $(this).addClass('js');
      
      // you can see we are using app.createLink() a reference to
      // our utility class outside of its own closure.
      app.createLink($(this).find('.employee'), "options", "toggle_options", true).click(function () {
        // grab a reference to the toggle link
        var link = $(this);
        
        //toggle the options table up and down
        $(this).siblings('.employee_options').slideToggle('slow', function () {
          // once the slideToggle has finished, work out whether to add
          // the selected class to the options link .. if the options block
          // has the css display property of 'block' we know that it is visible
          link.toggleClass('selected', ($(this).css('display') == "block"));
        });
        
        // always make the link active when it is clicked
        // to provide instant feedback to the user (it will update
        // once the slideToggle animation has finished)
        link.toggleClass('selected', true);
        
        // finally we hide the employee options, 
        // so they are hidden when the page loads
      }).siblings('.employee_options').hide();
    
      // apply our enableLabelToggle to each label in the options list, passing in
      // the relevant callback to fire once it is clicked
      $(this).find('.employee_options li.manager label').enableLabelToggle(employeeManagerCallback);
      $(this).find('.employee_options li.assistant label').enableLabelToggle(employeeAssistantCallback);
      $(this).find('.employee_options li.remove label').enableLabelToggle(employeeRemoveCallback);
    }
  });
  
})(jQuery);

$(document).ready(function () {
  $('#employee_update_settings').employeeWidget();
});