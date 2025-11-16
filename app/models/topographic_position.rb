class TopographicPosition < ApplicationRecord
  belongs_to :place, optional: true
end
