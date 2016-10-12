class Preparation < ActiveRecord::Base
  belongs_to :preparation_type
  belongs_to :stone
end
