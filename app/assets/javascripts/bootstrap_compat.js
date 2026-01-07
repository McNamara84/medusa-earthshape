(function($) {
  function anyModalOpen() {
    // Bootstrap 3 uses `.in`, Bootstrap 4/5 uses `.show`
    return $(".modal.in:visible, .modal.show:visible").length > 0;
  }

  function cleanupStaleModalArtifacts() {
    if (anyModalOpen()) return;

    // If a backdrop remains without an open modal, it will block clicks.
    $(".modal-backdrop").remove();

    // Bootstrap 3/4 add this to prevent scroll; if it lingers it can break UX.
    $("body").removeClass("modal-open");

    // Bootstrap sometimes sets inline padding-right to compensate scrollbar.
    $("body").css("padding-right", "");
  }

  $(document).on("hidden.bs.modal shown.bs.modal", ".modal", cleanupStaleModalArtifacts);

  $(document).ready(cleanupStaleModalArtifacts);

  // If Turbo is present, also re-run after navigation.
  $(document).on("turbo:load", cleanupStaleModalArtifacts);
})(jQuery);
