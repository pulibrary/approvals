# frozen_string_literal: true
require "rails_helper"

RSpec.describe StaffReportProcessor, type: :model do
  # rubocop:disable Layout/LineLength
  let(:heading_line) { "Department Number\tDepartment Name\tDepartment Long Name\tBsns Unit\tEID\tFirst Name\tMiddle Name\tLast Name\tNet ID\tPaid\tReg/Temp - Description\tPos #\tTitle\tRegister Title\tManager\tManager Net ID\tPosition Number\tCampus Address - Address 1\tCampus Address - Address 2\tCampus Address - Address 3\tCampus Address - City\tCampus Address - State\tCampus Address - Postal Code\tCampus Address - Country\tPhone\tE-Mail" }
  let(:user_line) { "90009\tTest Department\tTest Department Long\tPUHRS\t99999999\tI\tam\tTest\ttesti\tBiw\tR=BenElig\t000000000\tLibrary Office Assistant II\t\tManager, I Am.\timanager\t00001111\tResearch Collections\tForrestal Campus\t \tPrinceton\tNJ\t08544\tUSA\t609/111-2222\testi@prince.edu" }
  let(:manager_line) { "90009\tTest Department\tTest Department Long\tPUHRS\t99999991\tI\tam\tManager\timanager\tBiw\tR=BenElig\t000000000\tManager II\tLibrary, Dean of\t\tajarvis\t00001122\tResearch Collections\tForrestal Campus\t \tPrinceton\tNJ\t08544\tUSA\t609/111-2222\timanager@prince.edu" }
  let(:dean_line) { "41000\tTest Department\tTest Department Long\tPUHRS\t99999991\tAnn\t\tJarvis\tajarvis\tBiw\tR=BenElig\t000000000\tManager II\tLibrary, Dean of\t\tomanagert\t00001122\tResearch Collections\tForrestal Campus\t \tPrinceton\tNJ\t08544\tUSA\t609/111-2222\tajarvis@prince.edu" }
  # rubocop:enable Layout/LineLength
  let(:department_config) do
    "41000:\n  head_uid: ajarvis\n  admin_assistant: \n    - testi\n    - testi\n    - imanager\n"\
                            "90009:\n  admin_assistant: \n    - testabc"
  end
  class FakeLdapClass
    class << self
      def find_by_netid(net_id)
        @count ||= 0
        @count += 1
        address = "Firestone Library$Test Department"
        {
          address: address,
          department: "Library - Test Department",
          netid: net_id
        }
      end
    end
  end

  describe "#process" do
    it "creates users and staff profiles" do
      expect do
        described_class.process(data: "#{heading_line}\n#{user_line}", ldap_service_class: FakeLdapClass, department_config: department_config)
      end.to change(User, :count).by(1).and(
        change(StaffProfile, :count).by(1)
      ).and(
        change(Department, :count).by(1)
      ).and(
        change(Location, :count).by(1)
      ).and(
        change(Delegate, :count).by(0)
      )
      user_profile = StaffProfile.find_by(uid: "testi")
      expect(user_profile.given_name).to eq("I am")
      expect(user_profile.surname).to eq("Test")
      expect(user_profile.email).to eq("testi@princeton.edu")
      expect(user_profile.biweekly).to be_truthy
    end

    it "connects a user and their supervisor" do
      expect do
        described_class.process(data: "#{heading_line}\n#{user_line}\n#{manager_line}\n#{dean_line}", ldap_service_class: FakeLdapClass, department_config: department_config)
      end.to change(User, :count).by(3).and(
        change(StaffProfile, :count).by(3)
      ).and(
        change(Department, :count).by(2)
      ).and(
        change(Location, :count).by(1)
      ).and(
        change(Delegate, :count).by(2)
      )
      user_profile = StaffProfile.find_by(uid: "testi")
      supervisor_profile = StaffProfile.find_by(uid: "imanager")
      dean_profile = StaffProfile.find_by(uid: "ajarvis")
      library_main_department = Department.find_by(number: "41000")
      expect(user_profile.supervisor).to eq(supervisor_profile)
      expect(user_profile.reload.department.head).to eq(supervisor_profile)
      expect(library_main_department.head).to eq(dean_profile)
      expect(library_main_department.admin_assistants.map(&:uid)).to include("testi", "imanager")
    end

    it "updates a user if their information changes" do
      user = FactoryBot.create(:user, uid: "testi")
      staff_profile = FactoryBot.create :staff_profile, user: user
      ajarvis_user = FactoryBot.create(:user, uid: "ajarvis")
      FactoryBot.create :staff_profile, user: ajarvis_user
      expect do
        described_class.process(data: "#{heading_line}\n#{user_line}\n#{manager_line}\n#{dean_line}", ldap_service_class: FakeLdapClass, department_config: department_config)
      end.to change(User, :count).by(1).and(
        change(StaffProfile, :count).by(1)
      ).and(
        change(Department, :count).by(2)
      ).and(
        change(Location, :count).by(1)
      ).and(
        change(Delegate, :count).by(0)
      )
      staff_profile.reload
      supervisor_profile = StaffProfile.find_by(uid: "imanager")
      expect(staff_profile.supervisor).to eq(supervisor_profile)
      expect(staff_profile.department.head).to eq(supervisor_profile)
    end

    context "vacant supervisor" do
      # rubocop:disable Layout/LineLength
      let(:user_line2) { "90009\tTest Department\tTest Department Long\tPUHRS\t99999999\tI\tam2\tTest\ttest2\tBiw\tR=BenElig\t000000000\tLibrary Office Assistant II\t\tVacant\t\t00001111\tResearch Collections\tForrestal Campus\t \tPrinceton\tNJ\t08544\tUSA\t609/111-2222\testi@princeton.edu" }
      # rubocop:enable Layout/LineLength

      it "connects a user and the department head" do
        expect do
          described_class.process(data: "#{heading_line}\n#{user_line}\n#{user_line2}\n#{manager_line}\n#{dean_line}", ldap_service_class: FakeLdapClass, department_config: department_config)
        end.to change(User, :count).by(4).and(
          change(StaffProfile, :count).by(4)
        ).and(
          change(Department, :count).by(2)
        ).and(
          change(Location, :count).by(1)
        ).and(
          change(Delegate, :count).by(2)
        )
        user_profile = StaffProfile.find_by(uid: "test2")
        supervisor_profile = StaffProfile.find_by(uid: "imanager")
        expect(user_profile.supervisor).to eq(supervisor_profile)
      end
    end
  end
end
