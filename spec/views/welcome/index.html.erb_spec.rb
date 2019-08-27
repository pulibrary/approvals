# frozen_string_literal: true
require "rails_helper"

RSpec.describe "welcome/index", type: :view do
  it "renders attributes in <p>" do
    render
    expect(rendered).to include("Leave and Travel Requests")
    expect(rendered).to have_selector("hyperlink[href=\"/users/auth/cas\"]", text: "LOGIN with NetID")
  end
end
