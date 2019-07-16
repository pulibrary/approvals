# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def new_session_path(_scope)
    new_user_session_path
  end

  def current_staff_profile
    @staff_profile ||= StaffProfile.find_by(user_id: current_user.id)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || my_requests_path
  end
end
