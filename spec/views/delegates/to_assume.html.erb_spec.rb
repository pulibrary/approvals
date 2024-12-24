# frozen_string_literal: true

require "rails_helper"

RSpec.describe "delegates/to_assume", type: :view do
  let(:delegate1) { FactoryBot.create(:delegate) }
  let(:delegate2) { FactoryBot.create(:delegate) }

  before do
    assign(:delegators, [delegate1, delegate2])
  end

  it "renders a list of delegates" do
    render
    assert_select "lux-card-header", text: /^#{delegate1.delegator}*/, count: 1
    assert_select "lux-card-header", text: /#{delegate1.delegator.uid}/, count: 1
    assert_select "lux-card-header", text: /^#{delegate2.delegator}*/, count: 1
    assert_select "lux-card-header", text: /#{delegate2.delegator.uid}/, count: 1
  end
end
