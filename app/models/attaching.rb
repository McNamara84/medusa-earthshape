class Attaching < ApplicationRecord
  belongs_to :attachment_file
  belongs_to :attachable, polymorphic: true
  acts_as_list scope: [:attachable_id , :attachable_type], column: :position

  # Rails 5.1: Removed validates :attachment_file, existence: true - belongs_to (required by default) handles this
  validates :attachment_file_id, uniqueness: { scope: [:attachable_id, :attachable_type] }
end
