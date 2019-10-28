# frozen_string_literal: true
require "rails_helper"

RSpec.describe "delegates/show", type: :view do
  before do
    @delegate = assign(:delegate, FactoryBot.create(:delegate))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
  end
end
