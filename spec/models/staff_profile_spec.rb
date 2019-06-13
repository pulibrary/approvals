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

  describe "#department_head?" do
    it "returns false for a regular employee" do
      expect(staff_profile.department_head?).to be_falsey
    end

    context "when it is a department head" do
      subject(:staff_profile) { FactoryBot.create :staff_profile, :as_department_head }
      it "returns true for a department head" do
        expect(staff_profile.department_head?).to be_truthy
      end
    end
  end
end
