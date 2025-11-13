class Referring < ApplicationRecord
  belongs_to :bib
  belongs_to :referable, polymorphic: true

  # Rails 5.1: Removed validates :bib, existence: true - belongs_to (required by default) handles this
  validates :bib_id, uniqueness: { scope: [:referable_id, :referable_type] }
end
