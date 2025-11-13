class CategoryMeasurementItem < ApplicationRecord
  belongs_to :measurement_item
  belongs_to :measurement_category
  acts_as_list scope: :measurement_category, column: :position


  # Rails 5.1: Removed validates :measurement_item/:measurement_category, existence: true - belongs_to (required by default) handles this
  
  

end
