require "rails_helper"

RSpec.describe "staff_profiles/show", type: :view do
  let(:staff_profile) { FactoryBot.create(:staff_profile, :with_supervisor) }
  before do
    @staff_profile = assign(:staff_profile, staff_profile)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/#{staff_profile.user}/)
    expect(rendered).to match(/#{staff_profile.department}/)
    expect(rendered).to include staff_profile.supervisor.to_s
    expect(rendered).to match(/false/)
  end
end
