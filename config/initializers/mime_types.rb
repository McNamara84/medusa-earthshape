# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# Rails 6.0: PML (Phml Markup Language) for scientific data export
Mime::Type.register "application/xml", :pml

# Modal format for AJAX-loaded modal content
# Returns HTML fragments to be inserted into Bootstrap modals
Mime::Type.register "text/html", :modal
