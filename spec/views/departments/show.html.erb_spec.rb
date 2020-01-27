# frozen_string_literal: true
require "rails_helper"

RSpec.describe "departments/show", type: :view do
  let(:staff_profile) { FactoryBot.create(:staff_profile) }

  before do
    @department = assign(:department, FactoryBot.create(
                                        :department,
                                        name: "Name",
                                        head_id: 2,
                                        admin_assistant_ids: [staff_profile.id]
                                      ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/#{staff_profile.id}/)
  end
end
