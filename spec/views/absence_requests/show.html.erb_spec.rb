# frozen_string_literal: true
require "rails_helper"

RSpec.describe "absence_requests/show", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }
  let(:absence_request) { AbsenceRequestDecorator.new(FactoryBot.create(:absence_request, :with_note, creator: creator)) }
  before do
    @absence_request = assign(:absence_request, absence_request)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(absence_request.creator.given_name)
    expect(rendered).to match(/#{ absence_request.start_date.to_s}/)
    expect(rendered).to match(/#{ absence_request.end_date.to_s}/)
    expect(rendered).to match(/Sally wants to take a Vacation/)
    expect(rendered).to include("Notes from Sally Smith")
    expect(rendered).to include(absence_request.notes.first.content)
  end
end
