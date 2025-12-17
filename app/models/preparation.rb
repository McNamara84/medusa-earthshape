class Preparation < ApplicationRecord
  include Ransackable
  belongs_to :preparation_type, optional: true
  belongs_to :stone, optional: true
end
