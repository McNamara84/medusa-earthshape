class Device < ApplicationRecord
  include Ransackable
  has_many :analyses

  validates :name, presence: true, length: { maximum: 255 }
end
