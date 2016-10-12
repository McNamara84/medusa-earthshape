class Collector < ActiveRecord::Base
  belongs_to :stone
    validates :name, presence: true, length: { maximum: 255 }
end
