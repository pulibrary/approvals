# frozen_string_literal: true
require "rails_helper"

RSpec.describe "delegates/new", type: :view do
  before do
    assign(:delegate, FactoryBot.build(:delegate))
  end

  it "renders new delegate form" do
    render
    assert_select "form[action=?][method=?]", delegates_path, "post" do
      assert_select "input[name=?]", "delegate[delegate_id]"
    end
  end
end
