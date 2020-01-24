# frozen_string_literal: true

# Temporary controller file for welcome
#  todo: decide if this file should be deleted
class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # show the default page only for a non logged in user
    return unless current_user

    respond_to do |format|
      @request = nil
      format.html { redirect_to my_requests_path }
      format.json { redirect_to my_requests_path(format: :json) }
    end
  end
end
