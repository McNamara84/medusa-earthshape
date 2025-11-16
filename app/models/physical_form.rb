class PhysicalForm < ApplicationRecord
  has_many :stones

  validates :name, presence: true, length: {maximum: 255}
end
