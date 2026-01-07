## NOTE: intentionally left blank.
#
# This file previously monkeypatched `ActiveRecord::Associations::Builder::BelongsTo`
# to auto-generate `*_global_id` accessors for every `belongs_to` association.
#
# That approach was very invasive and brittle across Rails upgrades.
# The app now relies on explicit virtual attributes in the few models that
# actually need `*_global_id` in forms (e.g. `Stone`, `Box`, `Place`, `Analysis`).
