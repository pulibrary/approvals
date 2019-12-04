# frozen_string_literal: true
require "rails_helper"

RSpec.describe "delegates/index", type: :view do
  let(:delegate1) { FactoryBot.create(:delegate) }
  let(:delegate2) { FactoryBot.create(:delegate) }
  before do
    assign(:delegates, [delegate1, delegate2])
    assign(:delegate, FactoryBot.build(:delegate))
  end

  it "renders new delegate form" do
    render
    assert_select "form[action=?][method=?]", delegates_path, "post" do
      assert_select "input-autocomplete[name=?]", "delegate[delegate_id]"
    end
  end

  it "renders a list of delegates" do
    render
    assert_select "card-header", text: /^#{delegate1.delegate.full_name}*/, count: 1
    assert_select "card-header", text: /#{delegate1.delegate.uid}/, count: 1
    assert_select "card-header", text: /^#{delegate2.delegate.full_name}*/, count: 1
    assert_select "card-header", text: /#{delegate2.delegate.uid}/, count: 1
  end
end
