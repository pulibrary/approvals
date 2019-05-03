class StaffProfile < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :department, required: true
  belongs_to :supervisor, class_name: "User", optional: true

  def to_s
    "#{surname}, #{given_name} (#{user.uid})"
  end
end
