# frozen_string_literal: true
require "rails_helper"

RSpec.describe ApprovedRequestReport, type: :model do
    let(:report) { described_class.new(start_date: "06/01/2022", end_date: "12/31/2022") }
    let(:first_request) { FactoryBot.create(:travel_request) }
    it "can be instantiated" do
        expect(described_class.new(start_date: "06/01/2022", end_date: "12/31/2022"))
    end
    it "has a start date" do
        expect(report.start_date).to be_an_instance_of(Date)
        expect(report.start_date.day).to eq(1)
        expect(report.start_date.month).to eq(6)
    end
    it "has an end date" do
        expect(report.end_date).to be_an_instance_of(Date)
        expect(report.end_date.day).to eq(31)
        expect(report.end_date.month).to eq(12)
    end
    it "creates a CSV object" do
        expect(report.csv).to be_an_instance_of(CSV)
    end
    it "contains the correct data" do
        first_request.save
        expect(report.csv.headers.size).to eq(6)
      # expect(report.csv.first).to include ["2022-10-12", "2022-10-13", "Event 1 2022, Location", 3228]
    end
end
