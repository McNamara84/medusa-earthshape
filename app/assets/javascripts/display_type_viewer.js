(function($) {
  var changeDisplay = function(event) {
    event.preventDefault();
    var div_id = $(this).attr('href');
    $("div.display-type").children().addClass("hidden");
    $(div_id).removeClass("hidden");
    return false;
  };

  $(document).on("click", ".radio-button-group", changeDisplay);
}) (jQuery);