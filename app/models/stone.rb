class Stone < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile
  include HasRecursive
  include HasIgsn

  acts_as_taggable
 #with_recursive

  has_many :analyses
  has_many :children, class_name: "Stone", foreign_key: :parent_id, dependent: :nullify
  has_many :stones, class_name: "Stone", foreign_key: :parent_id, dependent: :nullify  
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  has_many :collectors
  belongs_to :parent, class_name: "Stone", foreign_key: :parent_id
  belongs_to :box
  belongs_to :place
  belongs_to :classification
  belongs_to :physical_form
  belongs_to :stonecontainer_type
  belongs_to :collection
  belongs_to :quantityunit
  belongs_to :collectionmethod
  has_many :preparations, dependent: :destroy

  accepts_nested_attributes_for :collectors, allow_destroy: true, reject_if: lambda {|attributes| attributes['name'].blank?}

  validates :box, presence: true
  validates :place, presence: true
  validates :collection, presence: true
  validates :stonecontainer_type, presence: true
  validates :quantity_initial, numericality: true
  validates :classification, presence: true
  validates :physical_form, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :sampledepth, numericality: true
  validates :date, presence: true 
  validates :igsn, uniqueness: true  , allow_nil: true, :allow_blank => true
  validate :parent_id_cannot_self_children, if: ->(stone) { stone.parent_id }
	  

  # def to_pml
  #   [self].to_pml
  # end

  def copy_associations (parent)
	Preparation.where(stone_id: parent.id).find_each do |parentprep|
		prep=parentprep.dup
		prep.stone_id=self.id
		prep.save
	end
  end

  private

  def parent_id_cannot_self_children
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

end
