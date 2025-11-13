class MeasurementItem < ApplicationRecord
  has_many :chemistries, dependent: :destroy
  has_many :category_measurement_items, dependent: :destroy
  has_many :measurement_categories, through: :category_measurement_items
  belongs_to :unit, optional: true  # Rails 5.1: Added optional: true (was validated with allow_nil: true)

  validates :nickname, presence: true, length: {maximum: 255}
  # Rails 5.1: Removed validates :unit, existence: true - belongs_to optional: true handles this

  scope :categorize, ->(measurement_category_id) { joins(:measurement_categories).where(measurement_categories: {id: measurement_category_id}) }
  
  def display_name
    display_in_html.blank? ? nickname : display_in_html
  end

  def tex_name
    display_in_tex.blank? ? nickname : display_in_tex
  end
end
