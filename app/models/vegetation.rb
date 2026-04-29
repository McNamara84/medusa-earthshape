class Vegetation < ApplicationRecord
  include Ransackable
  has_many :places, dependent: :nullify
end
