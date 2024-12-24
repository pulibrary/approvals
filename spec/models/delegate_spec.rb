# frozen_string_literal: true

require "rails_helper"

RSpec.describe Delegate, type: :model do
  describe "attributes of a delegate" do
    subject { described_class.new }

    it { is_expected.to respond_to :delegate_id }
    it { is_expected.to respond_to :delegate }
    it { is_expected.to respond_to :delegator_id }
    it { is_expected.to respond_to :delegator }
  end

  describe "Delegate creation" do
    it "Cannot create duplicate Delegates" do
      delegator = create(:staff_profile)
      delegate = create(:staff_profile)

      expect do
        described_class.create!(delegate:, delegator:)
      end.to change { described_class.count }.by(1)
      expect do
        described_class.create!(delegate:, delegator:)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect do
        described_class.create(delegate:, delegator:)
      end.not_to change { described_class.count }
    end
  end
end
