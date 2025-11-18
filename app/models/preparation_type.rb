class PreparationType < ApplicationRecord
  include Ransackable
  has_many :children, class_name: "PreparationType", foreign_key: :parent_id
  belongs_to :parent, class_name: "PreparationType", foreign_key: :parent_id, optional: true

  validates :name, presence: true, length: {maximum: 255}

  before_save :generate_full_name
  after_save  :reflection_child_full_name

  def generate_full_name
    if parent
      self.full_name = parent.full_name + ":" + name
    else
      self.full_name = name
    end
  end

  def reflection_child_full_name
    children.reload.map { |child| child.save }
  end
end
