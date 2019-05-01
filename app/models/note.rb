class Note < ApplicationRecord
  belongs_to :request
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
end
