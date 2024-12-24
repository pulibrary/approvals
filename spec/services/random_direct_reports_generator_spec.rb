# frozen_string_literal: true

require "rails_helper"

RSpec.describe RandomDirectReportsGenerator, type: :model do
  let(:supervisor) { FactoryBot.create :staff_profile }

  before do
    supervisor # call this here so we do not create the supervisor as part of the test
  end

  describe ".create_reports" do
    it "creates direct reports" do
      expect do
        described_class.create_reports(supervisor:)
      end.to change(StaffProfile, :count).by(5)
      expect(StaffProfile.where(supervisor_id: supervisor.id).count).to eq(5)
    end

    context "one report" do
      it "creates a direct report" do
        expect do
          described_class.create_reports(supervisor:, number_of_people: 1)
        end.to change(StaffProfile, :count).by(1)
        expect(StaffProfile.last.supervisor).to eq(supervisor)
        expect(StaffProfile.last.vacation_balance > 0).to be_truthy
        expect(StaffProfile.last.sick_balance > 0).to be_truthy
        expect(StaffProfile.last.personal_balance > 0).to be_truthy
      end
    end

    context "Random numbers collide" do
      it "creates a direct report" do
        allow(Random).to receive(:rand).with(1...50_000).and_return(10, 10, 100)
        expect do
          described_class.create_reports(supervisor:, number_of_people: 2)
        end.to change(StaffProfile, :count).by(2)
        expect(StaffProfile.last.supervisor).to eq(supervisor)
      end
    end
  end

  describe ".create_populated_department" do
    it "creates a departmemt with supervisors and direct reports" do
      expect do
        described_class.create_populated_department(head: supervisor, number_of_supervisors: 3)
      end.to change(Department, :count).by(1).and change(StaffProfile, :count).by(18)
      expect(StaffProfile.where(supervisor_id: supervisor.id).count).to eq(3)
      expect(Department.where(head_id: supervisor.id).count).to eq(1)
    end
  end
end
