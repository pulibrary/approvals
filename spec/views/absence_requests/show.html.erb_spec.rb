require "rails_helper"

RSpec.describe "absence_requests/show", type: :view do
  let(:absence_request) { FactoryBot.create(:absence_request, :with_note) }
  before do
    @absence_request = assign(:absence_request, absence_request)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(absence_request.creator.to_s)
    expect(rendered).to match(/#{ absence_request.start_date.to_s}/)
    expect(rendered).to match(/#{ absence_request.end_date.to_s}/)
    expect(rendered).to match(/#{ absence_request.absence_type}/)
    expect(rendered).to match(/#{ absence_request.status}/)
    expect(rendered).to include(absence_request.notes.first.content)
  end
end
