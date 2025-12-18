(function($) {
  $(document).on("click", "input.place-is-parent", function() {
	if ($(this).prop("checked")){
		$(this).closest("form").find("div.place-is-parent-select").hide();
	}else{
		$(this).closest("form").find("div.place-is-parent-select").show();	  
	}
  });
}) (jQuery);
