class Department < ApplicationRecord
  # TODO: remove the validtes and ass the belong_to when StaffProfile exists
  # belongs_to :head, class_name: 'StaffProfile', :optional
  # belongs_to :admin_assistant, class_name: 'StaffProfile', :optional

  validates :name, presence: true

  def to_s
    name
  end
end
