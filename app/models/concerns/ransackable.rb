# frozen_string_literal: true

# Ransackable concern
#
# Ransack 4.0+ requires explicit allowlisting of searchable/sortable attributes
# for security reasons. This concern provides sensible defaults by allowlisting
# all column names except sensitive fields.
#
# Usage:
#   class MyModel < ApplicationRecord
#     include Ransackable
#   end
#
# To customize, override in your model:
#   def self.ransackable_attributes(auth_object = nil)
#     super - ['sensitive_field'] + ['virtual_field']
#   end
module Ransackable
  extend ActiveSupport::Concern

  class_methods do
    # Define which attributes can be searched/sorted by Ransack
    #
    # By default, returns all column names except sensitive fields
    # Override in your model to customize
    def ransackable_attributes(auth_object = nil)
      # Get all column names
      column_names.reject do |name|
        # Exclude sensitive fields that should never be searchable
        name.in?(['encrypted_password', 'password_digest', 'password_reset_token', 'authentication_token'])
      end
    end

    # Define which associations can be searched by Ransack
    #
    # By default, returns all association names
    # Override in your model to customize
    def ransackable_associations(auth_object = nil)
      reflect_on_all_associations.map(&:name).map(&:to_s)
    end
  end
end
