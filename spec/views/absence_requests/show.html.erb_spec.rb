# frozen_string_literal: true

require "rails_helper"

RSpec.describe "absence_requests/show", type: :view do
  let(:creator) { create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }
  let(:absence_request) do
 AbsenceRequestDecorator.new(create(:absence_request, :with_note, creator:))
  end

  before do
    @request = assign(:request, absence_request)
  end

  it "renders attributes in" do
    without_partial_double_verification do
      allow(view).to receive(:current_staff_profile).and_return(creator)
      render
    end
    expect(rendered).to include(absence_request.creator.given_name)
    expect(rendered).to match(/Vacation \(#{Time.zone.now.strftime('%m/%d/%Y')} to #{Time.zone.tomorrow.strftime('%m/%d/%Y')}\)/)
    expect(rendered).to include("Sally Smith on")
    expect(rendered).to include(absence_request.notes.first.content)
    expect(rendered).to have_selector("lux-hyperlink[href=\"#{edit_absence_request_path(absence_request.id)}\"]",
                                      text: "Edit")
    expect(rendered).to have_selector("form[action=\"#{decide_absence_request_path(absence_request.id)}\"]")
    expect(rendered).to have_selector("lux-input-button", text: "Cancel")
  end

  context "not the creator" do
    it "renders attributes in" do
      without_partial_double_verification do
        allow(view).to receive(:current_staff_profile).and_return(nil)
        render
      end
      expect(rendered).not_to have_selector("lux-hyperlink[href=\"#{edit_absence_request_path(absence_request.id)}\"]",
                                            text: "Edit")
      expect(rendered).not_to have_selector("form[action=\"#{decide_absence_request_path(absence_request.id)}\"]")
    end
  end
end
