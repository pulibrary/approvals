# frozen_string_literal: true

# Temporary controller file for welcome
#  todo: decide if this file should be deleted
class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end
end
