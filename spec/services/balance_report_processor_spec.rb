# frozen_string_literal: true
require "rails_helper"

RSpec.describe BalanceReportProcessor, type: :model do
  # rubocop:disable Metrics/LineLength
  let(:heading_line) { "Business Unit\tDepartment\tNet ID\tEID\tEmployee Record Number\tName\tReg/Temp\tLatest Hire Dt\tTitle\tFLSA Status - Description\tSalary Administration Plan\tDuty Time\t# Pays\tStandard Hours\tUnion Code\tPay Group\tAbsence Grp\tBun Bal\tVac Bal\tSick Bal\tPer Bal\tAbsence Manager" }
  let(:user_line) { "PUHRS\tTest Department\ttesti\t99999999\t0\tTest, I am\tR\t2013-06-10 00:00:00\tLibrary Office Assistant II\tNonexempt\tBLR\t100\t26\t40\tLIB\tBCB\tPU_BCB\t\t118.783\t97.5\t15\tManager, I Am.\n" }
  let(:user2_line) { "PUHRS\tTest Department\ttest2\t99999999\t0\tTest, I too\tR\t2013-06-10 00:00:00\tLibrary Office Assistant II\tNonexempt\tBLR\t100\t26\t40\tLIB\tBCB\tPU_BCB\t\t108.783\t90.5\t16\tManager, I Am." }
  let(:user3_line) { "PUHRS\t41000 - Library - Main\ttest3\t99999999\t0\tTest,Exempt\tR\t2016-06-01 00:00:00\tExecutive Assistant\tExempt\tADM\t100\t12\t36.25\t \tMCM\tPU_MCM\t\t188.5\t108.75\t14.5\tJarvis,Anne E.\n" }
  # rubocop:enable Metrics/LineLength

  describe "#process" do
    it "Adds balances to staff profiles" do
      user = FactoryBot.create :user, uid: "testi"
      user2 = FactoryBot.create :user, uid: "test2"
      user3 = FactoryBot.create :user, uid: "test3"
      staff_profile = FactoryBot.create :staff_profile, user: user
      staff_profile2 = FactoryBot.create :staff_profile, user: user2
      staff_profile3 = FactoryBot.create :staff_profile, user: user3
      errors = described_class.process(data: "#{heading_line}\n#{user_line}\n#{user2_line}\n#{user3_line}")
      staff_profile.reload
      staff_profile2.reload
      staff_profile3.reload
      expect(errors[:unknown]).to be_empty
      expect(staff_profile.vacation_balance).to eq(118.783)
      expect(staff_profile.sick_balance).to eq(97.5)
      expect(staff_profile.personal_balance).to eq(15.0)
      expect(staff_profile.biweekly?).to be_truthy
      expect(staff_profile.standard_hours_per_week).to eq(40)
      expect(staff_profile2.vacation_balance).to eq(108.783)
      expect(staff_profile2.sick_balance).to eq(90.5)
      expect(staff_profile2.personal_balance).to eq(16.0)
      expect(staff_profile2.biweekly?).to be_truthy
      expect(staff_profile2.standard_hours_per_week).to eq(40)
      expect(staff_profile3.vacation_balance).to eq(188.5)
      expect(staff_profile3.sick_balance).to eq(108.75)
      expect(staff_profile3.personal_balance).to eq(14.5)
      expect(staff_profile3.biweekly?).to be_falsey
      expect(staff_profile3.standard_hours_per_week).to eq(36.25)
    end

    context "missing staff profile" do
      it "Adds balances to existing staff profiles and returns errors" do
        user = FactoryBot.create :user, uid: "testi"
        staff_profile = FactoryBot.create :staff_profile, user: user
        errors = described_class.process(data: "#{heading_line}\n#{user_line}\n#{user2_line}")
        expect(errors[:unknown]).to eq(["test2"])
        staff_profile.reload
        expect(staff_profile.vacation_balance).to eq(118.783)
        expect(staff_profile.sick_balance).to eq(97.5)
        expect(staff_profile.personal_balance).to eq(15.0)
      end
    end
  end
end
