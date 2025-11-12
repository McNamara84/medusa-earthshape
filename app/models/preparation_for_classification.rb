class PreparationForClassification < ApplicationRecord
  belongs_to :classification
  belongs_to :preparation_type
  
  validates :classification, existence: true, allow_nil: false
  validates :preparation_type, existence: true, allow_nil: false
end
