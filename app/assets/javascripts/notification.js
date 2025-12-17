(function($) {
  $.notification = {
    success: function(message) {
      notify("alert-success", "<i class='bi bi-check-circle'></i> Success", message);
    },
    warning: function(message) {
      notify("alert-warning", "<i class='bi bi-exclamation-circle'></i> Warning", message);
    },
    error: function(message) {
      notify("alert-danger", "<i class='bi bi-x-circle'></i> Error", message);
    },
    errorMessages: function(errors) {
      var $dl = $("<dl>");
      $dl.addClass("row");
      $.each(errors, function(key, message) {
        $dl.append("<dd>" + message + "</dd>");
      });
      $.notification.error($dl);
    },
    modalObject: function() {
      return $("#notification-modal");
    }
  };

  function notify(alertClass, title, message) {
    var $modal = $("#notification-modal");
    $modal.find("div.modal-header").removeClass("alert-success alert-warning alert-danger").addClass(alertClass);
    $("#notification-modal-label").html(title);
    $modal.find("div.modal-body").html(message);
    $modal.modal();
  }
}) (jQuery);
