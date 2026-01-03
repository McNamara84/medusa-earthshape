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

# Phase 2 (step 3): lock in the final state.
# We now fully disable Marshal by using JSON only.
Rails.application.config.action_dispatch.cookies_serializer = :json
