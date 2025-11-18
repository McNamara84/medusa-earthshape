class Collector < ApplicationRecord
  include Ransackable
  belongs_to :stone
    validates :name, presence: true, length: { maximum: 255 }
end
