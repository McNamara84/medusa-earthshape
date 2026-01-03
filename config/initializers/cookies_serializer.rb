# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
#
# Rails 4.x used Marshal by default. Using Marshal for cookies is discouraged because
# it allows object deserialization; while signing/encryption reduce attacker control,
# JSON is the safer modern format.
#
# Migration strategy:
# - :hybrid writes JSON but still reads legacy Marshal cookies ("json_allow_marshal").
# - This keeps existing sessions/cookies working while gradually migrating users.
# - After a deploy window (e.g. > session expiration), switch to :json to stop
#   accepting Marshal payloads entirely.
#
# Phase 2 (step 2): default to JSON to fully disable Marshal.
# If you need an emergency rollback, set `COOKIES_SERIALIZER=hybrid` temporarily.
serializer_env = ENV["COOKIES_SERIALIZER"]
serializer = (serializer_env && !serializer_env.strip.empty?) ? serializer_env.strip.downcase.to_sym : :json

unless %i[hybrid json].include?(serializer)
  raise ArgumentError, "Invalid COOKIES_SERIALIZER=#{serializer_env.inspect}. Allowed: hybrid, json."
end

Rails.application.config.action_dispatch.cookies_serializer = serializer
