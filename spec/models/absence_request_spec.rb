require "rails_helper"

RSpec.describe AbsenceRequest, type: :model do
  describe "attributes relevant to absence requests" do
    subject { described_class.new }
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :request_type }
    it { is_expected.to respond_to :absence_type }
    it { is_expected.to respond_to :notes }
  end
end
