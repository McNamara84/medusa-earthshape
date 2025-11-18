class Preparation < ApplicationRecord
  include Ransackable
  belongs_to :preparation_type
  belongs_to :stone
end
