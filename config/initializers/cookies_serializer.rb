# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
# Rails 6.0: Use :marshal for Devise compatibility (ActiveRecord session objects)
Rails.application.config.action_dispatch.cookies_serializer = :marshal
