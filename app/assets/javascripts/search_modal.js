(function($) {

  var input;

  function determine() {
    $(input).val($(this).data("id"));
    window.Medusa.ModalHelpers.hide($("#search-modal"));
    return false;
  }

  // Bind determine click handler, unbinding first to prevent memory leaks
  function bindDetermineHandler($modal) {
    $modal.find(".determine").off("click", determine).on("click", determine);
  }

  // Display error message in modal with XSS-safe text insertion
  function showModalError($modal, xhr) {
    var errorMessage = xhr.status ? (xhr.status + ' ' + xhr.statusText) : 'Unknown error';
    var $content = $(
      '<div class="modal-header alert alert-danger">' +
      '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>' +
      '<h4>Error</h4></div>' +
      '<div class="modal-body"><p class="error-message"></p></div>' +
      '<div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button></div>'
    );
    // Use text() to safely escape the error message (XSS prevention)
    $content.find('.error-message').text('Failed to load content: ' + errorMessage);
    $modal.find("div.modal-content").html($content);
  }

  // Bootstrap 5: Updated data attributes (data-bs-toggle, data-bs-target)
  // Also support legacy data-toggle for backward compatibility during migration
  $(document).on("click", "[data-bs-toggle='modal'][data-bs-target='#search-modal'], [data-toggle='modal'][data-target='#search-modal']", function(e) {
    e.preventDefault();
    var $link = $(this);
    var url = $link.attr("href");
    input = $link.data("input");

    // Show the modal first
    var $modal = $("#search-modal");
    $modal.find("div.modal-content").html('<div class="modal-body"><p>Loading...</p></div>');
    window.Medusa.ModalHelpers.show($modal);

    // Load the content via AJAX
    $.ajax({
      url: url,
      dataType: "html",
      success: function(data) {
        $modal.find("div.modal-content").html(data);
        bindDetermineHandler($modal);
      },
      error: function(xhr) {
        showModalError($modal, xhr);
      }
    });
  });

  // Handle show-modal for detail views (e.g., clicking a row to see details)
  $(document).on("click", "[data-bs-toggle='modal'][data-bs-target='#show-modal'], [data-toggle='modal'][data-target='#show-modal']", function(e) {
    e.preventDefault();
    var $link = $(this);
    var url = $link.attr("href");

    // Show the modal first
    var $modal = $("#show-modal");
    $modal.find("div.modal-content").html('<div class="modal-body"><p>Loading...</p></div>');
    window.Medusa.ModalHelpers.show($modal);

    // Load the content via AJAX
    $.ajax({
      url: url,
      dataType: "html",
      success: function(data) {
        $modal.find("div.modal-content").html(data);
      },
      error: function(xhr) {
        showModalError($modal, xhr);
      }
    });
  });

  // Handle AJAX form submissions within the modal (for search/filter)
  $(document).on("ajax:success", "#search-modal", function(event, data) {
    $(this).find("div.modal-content").html(data);
    bindDetermineHandler($(this));
  });

  // Bootstrap 5: Clean up modal instance on hide
  $(document).on("hidden.bs.modal", "#search-modal", function() {
    // Bootstrap 5 manages instances internally, no need to removeData
  });

  $(document).on("hidden.bs.modal", "#show-modal", function() {
    // Bootstrap 5 manages instances internally, no need to removeData
  });

})(jQuery);
