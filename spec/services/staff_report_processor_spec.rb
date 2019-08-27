# frozen_string_literal: true
require "rails_helper"

RSpec.describe StaffReportProcessor, type: :model do
  let(:heading_line) { "Department Number\tDepartment Name\tBsns Unit\tEID\tNet ID\tLast Name\tFirst Name\tMiddle Name\tPaid\tReg/Temp - Description\tPos #\tTitle\tAbsence Manager\tManager Net ID" }
  let(:user_line) { "90009\tTest Department\tPUHRS\t99999999\ttesti\tTest\tI\tam\tBiw\tR=BenElig\t000000000\tLibrary Office Assistant II\tManager, I Am.\timanager" }
  let(:manager_line) { "90009\tTest Department\tPUHRS\t99999991\timanager\tManager\tI\tam\tBiw\tR=BenElig\t000000000\tManager II\tLibrary, Dean of\tajarvis" }
  let(:dean_line) { "41000\tTest Department\tPUHRS\t99999991\tajarvis\tJarvis\tAnn\t\tBiw\tR=BenElig\t000000000\tManager II\tLibrary, Dean of\tomanager" }

  describe "#process" do
    it "creates users and staff profiles" do
      expect do
        StaffReportProcessor.process(data: "#{heading_line}\n#{user_line}")
      end.to change(User, :count).by(1).and(
        change(StaffProfile, :count).by(1)
      ).and(
        change(Department, :count).by(1)
      )
      user_profile = StaffProfile.find_by(uid: "testi")
      expect(user_profile.given_name).to eq("I am")
      expect(user_profile.surname).to eq("Test")
      expect(user_profile.email).to eq("testi@princeton.edu")
      expect(user_profile.biweekly).to be_truthy
    end

    it "connects a user and their supervisor" do
      StaffReportProcessor.process(data: "#{heading_line}\n#{user_line}\n#{manager_line}\n#{dean_line}")
      user_profile = StaffProfile.find_by(uid: "testi")
      supervisor_profile = StaffProfile.find_by(uid: "imanager")
      dean_profile = StaffProfile.find_by(uid: "ajarvis")
      library_main_department = Department.find_by(number: "41000")
      expect(user_profile.supervisor).to eq(supervisor_profile)
      expect(user_profile.reload.department.head).to eq(supervisor_profile)
      expect(library_main_department.head).to eq(dean_profile)
    end
  end
end
