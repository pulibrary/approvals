# frozen_string_literal: true
require "rails_helper"

RSpec.describe RequestReport, type: :model do
  let(:report) { described_class.new(start_date: "06/01/2022", end_date: "12/31/2022", file_path: file_path, approved_only: true) }
  let(:staff_member) { FactoryBot.create(:staff_profile, :with_department) }
  let(:request_one) do
    FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                start_date: "2022-10-12", end_date: "2022-10-14")
  end
  let(:file_path) { Rails.root.join("tmp", "approved_request_report_test.csv") }
  let(:department_head) { staff_member.department.head }

  around do |example|
    File.delete(file_path) if File.exist?(file_path)
    example.run
    File.delete(file_path) if File.exist?(file_path)
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

  it "has a file path" do
    expect(report.file_path).to eq file_path
  end

  it "creates a CSV file" do
    expect(File.exist?(file_path)).to be false
    report.csv
    expect(File.exist?(file_path)).to be true
  end

  describe "#in_report_period?" do
    let(:just_right_request) { request_one }
    let(:end_in_reporting_period) do
      FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                  start_date: "2022-5-28", end_date: "2022-06-03")
    end
    let(:beginning_in_reporting_period) do
      FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                  start_date: "2022-12-28", end_date: "2023-01-03")
    end
    let(:too_early_request) do
      FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                  start_date: "2022-04-08", end_date: "2022-04-11")
    end
    let(:too_late_request) do
      FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                  start_date: "2023-04-08", end_date: "2023-04-11")
    end

    it "returns true if any request dates are within reporting period" do
      expect(report.in_report_period?(just_right_request)).to eq(true)
      expect(report.in_report_period?(end_in_reporting_period)).to eq(true)
      expect(report.in_report_period?(beginning_in_reporting_period)).to eq(true)
    end

    it "returns false if request dates are outside of reporting period" do
      expect(report.in_report_period?(too_early_request)).to eq(false)
      expect(report.in_report_period?(too_late_request)).to eq(false)
    end
  end

  context "with a created CSV file" do
    let(:created_csv) { report.csv }
    let(:opened_csv) { CSV.parse(File.read(file_path), headers: true) }
    let(:first_row_hash) { opened_csv.first.to_hash }

    context "with an approved request" do
      before do
        request_one.approve!(agent: department_head)
        created_csv
      end

      it "has headers and values" do
        expect(opened_csv.headers.size).to eq(9)
        expect(first_row_hash["start_date"]).to eq("2022-10-12")
        expect(first_row_hash["end_date"]).to eq("2022-10-14")
        expect(first_row_hash["event_name"]).to match(/Event \d* \d*, Location/)
        expect(first_row_hash["trip_id"]).to eq(request_one.id.to_s)
        expect(first_row_hash["surname"]).to eq(staff_member.surname)
        expect(first_row_hash["given_name"]).to eq(staff_member.given_name)
        expect(first_row_hash["department"]).to eq(staff_member.department.name)
        expect(first_row_hash["estimated_cost"]).to eq("150.00")
        expect(first_row_hash["status"]).to eq("approved")
      end
    end
    context "with two approved requests" do
      let(:request_two) do
        FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                    start_date: "2022-10-12", end_date: "2022-10-14")
      end
      before do
        request_one.approve!(agent: department_head)
        request_two.approve!(agent: department_head)
        created_csv
      end

      it "only adds both approved requests" do
        expect(opened_csv.length).to eq(2)
      end
    end
    context "with one approved and one not-approved request" do
      let(:request_two) do
        FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                    start_date: "2022-10-12", end_date: "2022-10-14")
      end
      before do
        request_one.approve!(agent: department_head)
        request_two
        created_csv
      end

      context "with approved_only: true" do
        it "only adds the approved request" do
          expect(opened_csv.length).to eq(1)
        end
      end

      context "with approved_only: false" do
        let(:report) { described_class.new(start_date: "06/01/2022", end_date: "12/31/2022", file_path: file_path, approved_only: false) }
        it "adds both requests" do
          expect(opened_csv.length).to eq(2)
        end
        it "includes the correct status for the unapproved request" do
          expect(opened_csv[1]["status"]).to eq "pending"
        end
      end
    end

    context "with one approved and one denied request" do
      let(:request_two) do
        FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                    start_date: "2022-10-12", end_date: "2022-10-14")
      end
      before do
        request_one.approve!(agent: department_head)
        request_two.deny!(agent: department_head)
        created_csv
      end

      context "with approved_only: true" do
        it "only adds the approved request" do
          expect(opened_csv.length).to eq(1)
        end
      end

      context "with approved_only: false" do
        let(:report) { described_class.new(start_date: "06/01/2022", end_date: "12/31/2022", file_path: file_path, approved_only: false) }
        it "adds both requests" do
          expect(opened_csv.length).to eq(2)
        end
        it "includes the correct status for the denied request" do
          expect(opened_csv[1]["status"]).to eq "denied"
        end
      end
    end
    context "with one request in reporting period and others not" do
      let(:too_early_request) do
        FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                    start_date: "2022-04-08", end_date: "2022-04-11")
      end
      let(:too_late_request) do
        FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                    start_date: "2023-04-08", end_date: "2023-04-11")
      end
      before do
        request_one.approve!(agent: department_head)
        too_early_request.approve!(agent: department_head)
        too_late_request.approve!(agent: department_head)
        created_csv
      end
      it "only adds the request in the reporting period" do
        expect(opened_csv.length).to eq(1)
      end
    end
    context "with a request without a start date" do
      let(:request_two) do
        FactoryBot.create(:travel_request, :with_note_and_estimate, creator: staff_member,
                                                                    start_date: nil, end_date: "2022-10-14")
      end
      before do
        request_one.approve!(agent: department_head)
        request_two.approve!(agent: department_head)
        created_csv
      end

      it "does not raise an error" do
        expect do
          created_csv
        end.not_to raise_error
      end

      it "only adds the request in the reporting period" do
        expect(opened_csv.length).to eq(1)
      end
    end
  end
end
