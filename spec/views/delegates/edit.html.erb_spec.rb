# frozen_string_literal: true
require "rails_helper"

RSpec.describe "delegates/edit", type: :view do
  let(:delegate) { FactoryBot.create(:delegate) }
  before do
    assign(:delegate, delegate)
  end

  it "renders the edit delegate form" do
    render

    assert_select "form[action=?][method=?]", delegate_path(delegate), "post" do
      assert_select "input[name=?]", "delegate[delegate_id]"
    end
  end
end
