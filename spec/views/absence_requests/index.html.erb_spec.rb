require "rails_helper"

RSpec.describe "absence_requests/index", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile) }
  before do
    assign(:absence_requests, [
             AbsenceRequest.create!(
               creator_id: creator.id
             ),
             AbsenceRequest.create!(
               creator_id: creator.id
             )
           ])
  end

  it "renders a list of absence_requests" do
    render
  end
end
