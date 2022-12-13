# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Delegate", type: :system do
    it "displays an error when creating a duplicate delegate" do
        delegator = FactoryBot.create(:staff_profile)
        delegate = FactoryBot.create(:staff_profile)
  
        Delegate.create!(delegate: delegate, delegator: delegator)
        login_as(delegator)
        visit "/my_requests"
    end
end

