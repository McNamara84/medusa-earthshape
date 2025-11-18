class TopographicPosition < ApplicationRecord
  include Ransackable
  belongs_to :place, optional: true
end
