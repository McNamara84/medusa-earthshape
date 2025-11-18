class Collection < ApplicationRecord
  include Ransackable
  include HasRecordProperty
  include HasAttachmentFile
#  belongs_to :collectionmethod
  has_many :stones
  has_many :places, through: :stones
  has_many :collectors, through: :stones
  has_many :collectionmethods, through: :stones  
  has_many :referrings, as: :referable, dependent: :destroy
  validates :name, presence: true, length: { maximum: 255 }
  validates :project, presence: true, length: { maximum: 255 }  
  validates :samplingstrategy, presence: true, length: { maximum: 255 }
end
