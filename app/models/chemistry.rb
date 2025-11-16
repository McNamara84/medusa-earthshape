class Chemistry < ApplicationRecord
  include HasRecordProperty

  belongs_to :analysis
  belongs_to :measurement_item
  belongs_to :unit, optional: true  # Rails 5.1: Added optional: true (was validated with allow_nil: true)

  # Rails 5.1: Removed validates :analysis/:measurement_item/:unit, existence: true - belongs_to handles this
  validates :value, numericality: true
  validates :uncertainty, numericality: true, allow_nil: true

  def display_name
     if self.value==0.0 && !self.description.blank?
	"#{measurement_item.display_name}: #{self.description}"
    else
    	"#{measurement_item.display_name}: #{sprintf("%.2f", self.value)}"
    end
  end
end
