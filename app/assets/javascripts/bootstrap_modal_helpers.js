(function($) {
  var warnedMissingApiOnce = false;

  // Compatibility layer for mixed Bootstrap versions.
  // - Bootstrap 5 provides `bootstrap.Modal`
  // - Bootstrap 3/4 commonly use jQuery's `$().modal()` API
  // Views may include both `data-dismiss` and `data-bs-dismiss` attributes to
  // support legacy and newer markup.
  function warnMissingApi(element) {
    if (warnedMissingApiOnce) {
      return;
    }

    try {
      if (element && element.getAttribute && element.getAttribute("data-medusa-modal-api-warning") === "1") {
        warnedMissingApiOnce = true;
        return;
      }

      if (element && element.setAttribute) {
        element.setAttribute("data-medusa-modal-api-warning", "1");
      }
    } catch (e) {
      if (window.console && console.warn) {
        console.warn("Unable to set modal API warning flag.", e);
      }
    }

    if (window.console && console.warn) {
      warnedMissingApiOnce = true;
      console.warn(
        "Modal API not available (neither Bootstrap.Modal nor jQuery modal).",
        element
      );
    }
  }

  function elementFrom(modal) {
    if (!modal) return null;
    if (modal.jquery) return modal[0] || null;
    return modal;
  }

  function ensureJquery(modal) {
    if (!modal) return null;
    if (modal.jquery) return modal;
    return $(modal);
  }

  function showModal(modal) {
    var element = elementFrom(modal);

    if (window.bootstrap && bootstrap.Modal && element) {
      var modalInstance = bootstrap.Modal.getOrCreateInstance(element);
      modalInstance.show();
      return;
    }

    var $modal = ensureJquery(modal);
    if ($modal && typeof $modal.modal === "function") {
      $modal.modal("show");
      return;
    }

    warnMissingApi(element);
  }

  function hideModal(modal) {
    var element = elementFrom(modal);

    if (window.bootstrap && bootstrap.Modal && element) {
      var modalInstance = bootstrap.Modal.getInstance(element);
      if (modalInstance) modalInstance.hide();
      return;
    }

    var $modal = ensureJquery(modal);
    if ($modal && typeof $modal.modal === "function") {
      $modal.modal("hide");
      return;
    }

    warnMissingApi(element);
  }

  window.Medusa = window.Medusa || {};
  window.Medusa.ModalHelpers = {
    show: showModal,
    hide: hideModal
  };
})(jQuery);
