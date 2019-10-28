# frozen_string_literal: true
require "rails_helper"

RSpec.describe "delegates/index", type: :view do
  let(:delegate1) { FactoryBot.create(:delegate) }
  let(:delegate2) { FactoryBot.create(:delegate) }
  before do
    assign(:delegates, [delegate1, delegate2])
  end

  it "renders a list of delegates" do
    render
    assert_select "tr>td", text: delegate1.delegate.to_s, count: 1
    assert_select "tr>td", text: delegate2.delegate.to_s, count: 1
  end
end
