class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user

  # Rails 5.1: Removed validates :group/:user, existence: true - belongs_to (required by default) handles this
  # TODO groupの新規作成時にexistenceバリデーションが掛かるためコメントアウト
  # validates :user, existence: true
end
