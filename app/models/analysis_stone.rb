class AnalysisStone < ApplicationRecord
  belongs_to :stone
  belongs_to :analysis
  validates_uniqueness_of :stone_id, :scope => :analysis_id 
end
