# frozen_string_literal: true

require "rails_helper"

describe "_flash_messages.html.erb" do
  let(:partial) { "shared/flash_messages" }

  before do
    flash[flash_key] = flash_message
    render partial: partial
  end
  context "success" do
    let(:flash_key) { "success" }
    let(:flash_message) { "A Sucessful completion" }
    it "displays an alert" do
      expect(rendered).to have_selector("alert[status=\"success\"]", text: flash_message)
    end
  end

  context "notice" do
    let(:flash_key) { "notice" }
    let(:flash_message) { "A notice completion" }
    it "displays an alert" do
      expect(rendered).to have_selector("alert[status=\"info\"]", text: flash_message)
    end
  end

  context "error" do
    let(:flash_key) { "error" }
    let(:flash_message) { "An error" }
    it "displays an alert" do
      expect(rendered).to have_selector("alert[status=\"error\"]", text: flash_message)
    end
  end

  context "alert" do
    let(:flash_key) { "alert" }
    let(:flash_message) { "An alert for you" }
    it "displays an alert" do
      expect(rendered).to have_selector("alert[status=\"warning\"]", text: flash_message)
    end
  end
end
