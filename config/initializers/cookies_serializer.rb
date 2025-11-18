# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
#
# Rails 6.0: Using :marshal for Devise compatibility
# 
# SECURITY NOTE: Marshal serialization allows arbitrary code execution if an attacker
# can manipulate cookie data. However, Rails mitigates this risk by:
# 1. Signing all cookies with secret_key_base (prevents tampering)
# 2. Encrypting session cookies (prevents reading/modifying content)
# 3. Only deserializing data that passes signature verification
#
# This change is necessary because:
# - Devise stores Warden::Proxy objects in sessions
# - These objects cannot be serialized to JSON
# - Rails 4.x used :marshal by default
# - Switching back maintains backward compatibility with existing sessions
#
# All cookies in this application are signed and encrypted, making Marshal safe to use.
# If additional cookie-based features are added, ensure they also use signed/encrypted cookies.
Rails.application.config.action_dispatch.cookies_serializer = :marshal
