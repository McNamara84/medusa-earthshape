(function($) {

  var input;

  function determine() {
    $(input).val($(this).data("id"));
    $("#search-modal").modal("hide");
    return false;
  }

  // Bootstrap 3 removed the automatic remote loading feature for modals.
  // We need to manually load the content via AJAX when the modal link is clicked.
  $(document).on("click", "[data-toggle='modal'][data-target='#search-modal']", function(e) {
    e.preventDefault();
    var $link = $(this);
    var url = $link.attr("href");
    input = $link.data("input");

    // Show the modal first
    var $modal = $("#search-modal");
    $modal.find("div.modal-content").html('<div class="modal-body"><p>Loading...</p></div>');
    $modal.modal("show");

    // Load the content via AJAX
    $.ajax({
      url: url,
      dataType: "html",
      success: function(data) {
        $modal.find("div.modal-content").html(data);
        // Bind the determine function to the selection links
        $modal.find(".determine").on("click", determine);
      },
      error: function(xhr, status, error) {
        $modal.find("div.modal-content").html(
          '<div class="modal-header alert alert-danger">' +
          '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
          '<h4>Error</h4></div>' +
          '<div class="modal-body"><p>Failed to load content: ' + error + '</p></div>' +
          '<div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">Close</button></div>'
        );
      }
    });
  });

  // Handle show-modal for detail views (e.g., clicking a row to see details)
  $(document).on("click", "[data-toggle='modal'][data-target='#show-modal']", function(e) {
    e.preventDefault();
    var $link = $(this);
    var url = $link.attr("href");

    // Show the modal first
    var $modal = $("#show-modal");
    $modal.find("div.modal-content").html('<div class="modal-body"><p>Loading...</p></div>');
    $modal.modal("show");

    // Load the content via AJAX
    $.ajax({
      url: url,
      dataType: "html",
      success: function(data) {
        $modal.find("div.modal-content").html(data);
      },
      error: function(xhr, status, error) {
        $modal.find("div.modal-content").html(
          '<div class="modal-header alert alert-danger">' +
          '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
          '<h4>Error</h4></div>' +
          '<div class="modal-body"><p>Failed to load content: ' + error + '</p></div>' +
          '<div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">Close</button></div>'
        );
      }
    });
  });

  // Handle AJAX form submissions within the modal (for search/filter)
  $(document).on("ajax:success", "#search-modal", function(event, data, status) {
    $(this).find("div.modal-content").html(data);
    // Re-bind the determine function after content update
    $(this).find(".determine").on("click", determine);
  });

  $(document).on("hidden.bs.modal", "#search-modal", function() {
    $(this).removeData("bs.modal");
  });

  $(document).on("hidden.bs.modal", "#show-modal", function() {
    $(this).removeData("bs.modal");
  });

}) (jQuery);
