# frozen_string_literal: true
require "rails_helper"

RSpec.describe "welcome/index", type: :view do
  it "renders attributes in <p>" do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(nil)
      render
    end
    render
    expect(rendered).to include("Absence and Travel Requests")
    expect(rendered).to have_selector("lux-hyperlink[href=\"/users/auth/cas\"]", text: "LOGIN with NetID")
  end

  it "renders logout if current profile is set" do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return("abc")
      render
    end
    expect(rendered).to include("Absence and Travel Requests")
    expect(rendered).to have_selector("lux-hyperlink[href=\"/sign_out\"]", text: "LOGOUT")
  end
end
