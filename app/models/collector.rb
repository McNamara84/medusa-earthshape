class Collector < ApplicationRecord
  belongs_to :stone
    validates :name, presence: true, length: { maximum: 255 }
end
