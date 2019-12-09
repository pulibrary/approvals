# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def new_session_path(_scope)
    new_user_session_path
  end

  # rubocop: disable Style/SafeNavigation
  def current_delegate
    delegate_id = session[:approvals_delegate]
    load_delegate(delegate_id) if delegate_id.present? && (@current_delegate.blank? || @current_delegate.id != delegate_id)
    @current_delegate
  end
  helper_method :current_delegate

  def current_staff_profile
    delegate = current_delegate
    if delegate.present?
      delegate.delegator.current_delegate = delegate.delegate
      delegate.delegator
    else
      @current_staff_profile ||= StaffProfile.find_by(user_id: current_user.id)
    end
  end
  helper_method :current_staff_profile

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || my_requests_path
  end

  private

    def load_delegate(delegate_id)
      @current_delegate = Delegate.find(delegate_id)
      if @current_delegate && @current_delegate.delegate.user != current_user
        session[:approvals_delegate] = nil
        @current_delegate = nil
      end
    rescue ActiveRecord::RecordNotFound
      session[:approvals_delegate] = nil
      @current_delegate = nil
    end
end
