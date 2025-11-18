class Vegetation < ApplicationRecord
  include Ransackable
  belongs_to :place
end
