# frozen_string_literal: true
require "rails_helper"

RSpec.describe AbsenceRequest, type: :model do
  describe "attributes relevant to absence requests" do
    subject { described_class.new }
    it { is_expected.to respond_to :absence_type }
    it { is_expected.to respond_to :creator }
    it { is_expected.to respond_to :end_date }
    it { is_expected.to respond_to :end_time }
    it { is_expected.to respond_to :hours_requested }
    it { is_expected.to respond_to :notes }
    it { is_expected.to respond_to :start_date }
    it { is_expected.to respond_to :start_time }
    it { is_expected.to respond_to :status }
  end
end
