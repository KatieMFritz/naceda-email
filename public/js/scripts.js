$('form').live('submit', function(){
    $.post($(this).attr('action'), $(this).serialize(), function(response){
          alert("Hey!");
    },'json');
    return false;
 });
