class Collectionmethod < ApplicationRecord
  include Ransackable
	 has_many :stones
end
