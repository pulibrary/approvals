# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Delegate", type: :system do
    it "displays an error when creating a duplicate delegate" do
        delegator_user = create(:user)
        create(:staff_profile, user: delegator_user)
        delegate_profile = create(:staff_profile)

        login_as(delegator_user)
        visit "/delegates"

        2.times do
            fill_in "displayInput", with: delegate_profile.user.uid
            find(".lux-autocomplete-result", match: :first).click
            click_button "Add Delegate"
            expect(page).to have_content "Please use this feature with care"
        end
        expect(page).to have_content "1 error prohibited this delegate from being saved"
    end
end
