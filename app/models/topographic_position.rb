class TopographicPosition < ApplicationRecord
  include Ransackable
  has_many :places, dependent: :nullify
end
