# frozen_string_literal: true
require "rails_helper"

RSpec.describe StaffReportProcessor, type: :model do
  let(:heading_line) { "Department Number\tDepartment Name\tBsns Unit\tEID\tNet ID\tLast Name\tFirst Name\tMiddle Name\tPaid\tReg/Temp - Description\tPos #\tTitle\tAbsence Manager\tManager Net ID" }
  let(:user_line) { "90009\tTest Department\tPUHRS\t99999999\ttesti\tTest\tI\tam\tBiw\tR=BenElig\t000000000\tLibrary Office Assistant II\tManager, I Am.\timanager" }
  let(:manager_line) { "90009\tTest Department\tPUHRS\t99999991\timanager\tManager\tI\tam\tBiw\tR=BenElig\t000000000\tManager II\tLibrary, Dean of\tajarvis" }
  let(:dean_line) { "41000\tTest Department\tPUHRS\t99999991\tajarvis\tJarvis\tAnn\t\tBiw\tR=BenElig\t000000000\tManager II\tLibrary, Dean of\tomanager" }

  class FakeLdapClass
    class << self
      def find_by_netid(net_id)
        {
          address: "Firestone Library$Test Department",
          department: "Library - Test Department",
          netid: net_id
        }
      end
    end
  end

  describe "#process" do
    it "creates users and staff profiles" do
      expect do
        StaffReportProcessor.process(data: "#{heading_line}\n#{user_line}", ldap_service_class: FakeLdapClass)
      end.to change(User, :count).by(1).and(
        change(StaffProfile, :count).by(1)
      ).and(
        change(Department, :count).by(1)
      ).and(
        change(Location, :count).by(1)
      )
      user_profile = StaffProfile.find_by(uid: "testi")
      expect(user_profile.given_name).to eq("I am")
      expect(user_profile.surname).to eq("Test")
      expect(user_profile.email).to eq("testi@princeton.edu")
      expect(user_profile.biweekly).to be_truthy
    end

    it "connects a user and their supervisor" do
      expect do
        StaffReportProcessor.process(data: "#{heading_line}\n#{user_line}\n#{manager_line}\n#{dean_line}", ldap_service_class: FakeLdapClass)
      end.to change(User, :count).by(3).and(
        change(StaffProfile, :count).by(3)
      ).and(
        change(Department, :count).by(2)
      ).and(
        change(Location, :count).by(1)
      )
      user_profile = StaffProfile.find_by(uid: "testi")
      supervisor_profile = StaffProfile.find_by(uid: "imanager")
      dean_profile = StaffProfile.find_by(uid: "ajarvis")
      library_main_department = Department.find_by(number: "41000")
      expect(user_profile.supervisor).to eq(supervisor_profile)
      expect(user_profile.reload.department.head).to eq(supervisor_profile)
      expect(library_main_department.head).to eq(dean_profile)
    end

    it "updates a user if their information changes" do
      user = FactoryBot.create(:user, uid: "testi")
      staff_profile = FactoryBot.create :staff_profile, user: user
      expect do
        StaffReportProcessor.process(data: "#{heading_line}\n#{user_line}\n#{manager_line}\n#{dean_line}", ldap_service_class: FakeLdapClass)
      end.to change(User, :count).by(2).and(
        change(StaffProfile, :count).by(2)
      ).and(
        change(Department, :count).by(2)
      ).and(
        change(Location, :count).by(1)
      )
      staff_profile.reload
      supervisor_profile = StaffProfile.find_by(uid: "imanager")
      expect(staff_profile.supervisor).to eq(supervisor_profile)
      expect(staff_profile.department.head).to eq(supervisor_profile)
    end

    context "vacant supervisor" do
      let(:user_line2) { "90009\tTest Department\tPUHRS\t99999998\ttest2\tTest\tI\tam2\tBiw\tR=BenElig\t000000000\tLibrary Office Assistant II\tVacant\t" }

      it "connects a user and the department head" do
        expect do
          StaffReportProcessor.process(data: "#{heading_line}\n#{user_line}\n#{user_line2}\n#{manager_line}\n#{dean_line}", ldap_service_class: FakeLdapClass)
        end.to change(User, :count).by(4).and(
          change(StaffProfile, :count).by(4)
        ).and(
          change(Department, :count).by(2)
        ).and(
          change(Location, :count).by(1)
        )
        user_profile = StaffProfile.find_by(uid: "test2")
        supervisor_profile = StaffProfile.find_by(uid: "imanager")
        expect(user_profile.supervisor).to eq(supervisor_profile)
      end
    end
  end
end
