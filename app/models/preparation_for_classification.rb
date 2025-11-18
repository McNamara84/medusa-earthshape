class PreparationForClassification < ApplicationRecord
  include Ransackable
  belongs_to :classification
  belongs_to :preparation_type
  
  # Rails 5.1: Removed validates :classification/:preparation_type, existence: true - belongs_to (required by default) handles this
end
