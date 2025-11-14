class AddFiletopicRefToAttachmentFile < ActiveRecord::Migration[4.2]
  def change
    add_reference :attachment_files, :filetopic, index: true
  end
end
