# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :rememberable, :omniauthable

  has_many :requests
  has_one :staff_profile

  def self.from_cas(access_token)
    User.find_by(provider: access_token.provider, uid: access_token.uid&.downcase)
  end

  def to_s
    uid
  end
end
