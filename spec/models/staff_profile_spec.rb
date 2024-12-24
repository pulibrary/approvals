# frozen_string_literal: true

require "rails_helper"

RSpec.describe StaffProfile, type: :model do
  subject(:staff_profile) { described_class.new }

  it { is_expected.to respond_to :user }
  it { is_expected.to respond_to :user_id }
  it { is_expected.to respond_to :department }
  it { is_expected.to respond_to :department_id }
  it { is_expected.to respond_to :supervisor }
  it { is_expected.to respond_to :supervisor_id }
  it { is_expected.to respond_to :biweekly }
  it { is_expected.to respond_to :given_name }
  it { is_expected.to respond_to :surname }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :location }
  it { is_expected.to respond_to :vacation_balance }
  it { is_expected.to respond_to :sick_balance }
  it { is_expected.to respond_to :personal_balance }
  it { is_expected.to respond_to :current_delegate }
  it { is_expected.to respond_to :standard_hours_per_week }

  describe "#find_by_uid" do
    it "returns the staff_profile" do
      profile = create(:staff_profile)
      expect(described_class.find_by(uid: profile.user.uid)).to eq(profile)
    end

    it "returns nil for a non existant uid" do
      expect(described_class.find_by(uid: "blah")).to be_nil
    end
  end

  describe "#department_head?" do
    it "returns false for a regular employee" do
      expect(staff_profile.department_head?).to be_falsey
    end

    context "when it is a department head" do
      subject(:staff_profile) { create(:staff_profile, :as_department_head) }

      it "returns true for a department head" do
        expect(staff_profile.department_head?).to be_truthy
      end
    end
  end

  describe "#supervisor?" do
    it "returns false for a regular employee" do
      expect(staff_profile.supervisor?).to be_falsey
    end

    context "when it is a supervisor" do
      it "returns true for a department head" do
        create(:staff_profile, supervisor: staff_profile)
        expect(staff_profile.supervisor?).to be_truthy
      end
    end
  end

  describe "#full_name" do
    it "returns the staff_profile" do
      profile = create(:staff_profile, given_name: "Jane", surname: "Doe")
      expect(profile.full_name).to eq("Jane Doe")
    end
  end

  describe "#delegate" do
    it "sets the delegate" do
      profile = create(:staff_profile, given_name: "Jane", surname: "Doe")
      profile2 = create(:staff_profile, supervisor: staff_profile)
      profile.current_delegate = profile2
      expect(profile.current_delegate).to eq(profile2)
    end
  end

  describe "#admin_assistant" do
    it "returns based on location" do
      aa = create(:staff_profile, given_name: "Doug", surname: "Doe")
      aa2 = create(:staff_profile, given_name: "Sally", surname: "Smith")
      location = create(:location, admin_assistant: aa)
      department = create(:department, admin_assistants: [aa2])
      profile = create(:staff_profile, location:, department:)
      expect(profile.admin_assistants).to eq([aa])
    end

    it "returns based on department" do
      aa = create(:staff_profile, given_name: "Doug", surname: "Doe")
      location = create(:location)
      department = create(:department, admin_assistants: [aa])
      profile = create(:staff_profile, location:, department:)
      expect(profile.admin_assistants).to eq([aa])
    end

    it "returns all department members" do
      aa = create(:staff_profile, given_name: "Doug", surname: "Doe")
      department1 = create(:department, admin_assistants: [aa])
      department2 = create(:department, admin_assistants: [])
      profile1 = create(:staff_profile, given_name: "Sally", surname: "Smith", department: department1)
      create(:staff_profile, given_name: "Jane", surname: "Smith", department: department2)
      expect(aa.list_supervised(list: [])).to include(aa, profile1)
    end
  end

  describe "#staff_list_json" do
    it "handles staff names with apostrophes" do
      profile = create(:staff_profile, given_name: "Georgia",
                                       surname: "O'Keeffe",
                                       id: 100,
                                       user: create(:user, uid: "uid123"))
      profile.staff_list_json
      expect(profile.staff_list_json).to eq("[{ id: '100', label: 'O\\'Keeffe, Georgia (uid123)' }]")
    end
  end
end
