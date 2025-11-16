class GlobalQr < ApplicationRecord
  belongs_to :record_property

  # Rails 5.1: Removed validates :record_property, existence: true - belongs_to (required by default) handles this
end
