# frozen_string_literal: true
require "rails_helper"

RSpec.describe "absence_requests/show", type: :view do
  let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }
  let(:absence_request) { AbsenceRequestDecorator.new(FactoryBot.create(:absence_request, :with_note, creator: creator)) }
  before do
    @request = assign(:request, absence_request)
  end

  it "renders attributes in" do
    render
    expect(rendered).to include(absence_request.creator.given_name)
    expect(rendered).to match(/Vacation \(#{Time.zone.now.strftime('%m/%d/%Y')} to #{Time.zone.tomorrow.strftime('%m/%d/%Y')}\)/)
    expect(rendered).to include("Sally Smith on")
    expect(rendered).to include(absence_request.notes.first.content)
    expect(rendered).to have_selector("hyperlink[href=\"#{edit_absence_request_path(absence_request.id)}\"]", text: "Edit")
    expect(rendered).to have_selector("hyperlink[href=\"#{my_requests_path}\"]", text: "Back")
  end
end
