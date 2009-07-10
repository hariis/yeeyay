$(function(){	
        // Tabs
        $j('#tabs').tabs();	


        //hover states on the static widgets
        $j('#dialog_link, ul#icons li').hover(
                function() { $j(this).addClass('ui-state-hover'); }, 
                function() { $j(this).removeClass('ui-state-hover'); }
        );

});

//$(document).ajaxSend(function(event, request, settings) {
//  if (typeof(AUTH_TOKEN) == "undefined") return;
//  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
//  settings.data = settings.data || "";
//  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
//});

