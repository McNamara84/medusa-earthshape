class Box < ApplicationRecord
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile
  include HasRecursive

  acts_as_taggable
  #with_recursive

  has_many :users
  has_many :stones
  has_many :boxes, class_name: "Box", foreign_key: :parent_id, dependent: :nullify
  has_many :children, class_name: "Box", foreign_key: :parent_id, dependent: :nullify
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  belongs_to :parent, class_name: "Box", foreign_key: :parent_id, optional: true
  belongs_to :box_type, optional: true

  # Virtual attribute for forms: allows setting parent via global_id
  def parent_global_id
    parent&.global_id
  end
  
  def parent_global_id=(global_id)
    return if global_id.blank?
    record_property = RecordProperty.find_by(global_id: global_id)
    self.parent_id = record_property&.datum_id if record_property&.datum_type == 'Box'
  end

  # Rails 5.1: Removed validates :box_type/:parent_id, existence: true - belongs_to optional: true handles this
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :parent_id }
  validate :parent_id_cannot_self_children, if: ->(box) { box.parent_id }

  after_save :reset_path

  def analyses
    analyses = []
    stones.each do |stone| 
      (analyses = analyses + stone.analyses) unless stone.analyses.empty?
    end
    analyses
  end

  def get_building()
    if parent
      return parent.get_building()
    else
      return name
    end
  end

  private

  def parent_id_cannot_self_children
    # Reload children association to ensure we have current data from database
    # This is necessary because descendants() uses the children association,
    # which may be cached with stale data
    children.reload if children.loaded?
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

  def reset_path
    self.path = ""
    self.update_column(:path, "/#{self.ancestors.reverse.map(&:name).join('/')}") if self.parent
  end

end
