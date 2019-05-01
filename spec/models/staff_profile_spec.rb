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
end
