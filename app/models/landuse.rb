class Landuse < ApplicationRecord
  include Ransackable
  belongs_to :place
end
