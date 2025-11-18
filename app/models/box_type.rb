class BoxType < ApplicationRecord
  include Ransackable
  has_many :boxes

  validates :name, presence: true, length: {maximum: 255}
end
