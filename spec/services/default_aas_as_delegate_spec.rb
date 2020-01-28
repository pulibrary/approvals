# frozen_string_literal: true
require "rails_helper"

RSpec.describe DefaultAasAsDelegate, type: :model do
  describe "#run" do
    it "assigns a delegate to every person who has an AA" do
      staff_profile = FactoryBot.create :staff_profile
      staff_profile2 = FactoryBot.create :staff_profile, :with_department
      expect { described_class.run }.to change(Delegate, :count).by(3)
      expect(Delegate.where(delegator: staff_profile).count).to eq(0)
      expect(Delegate.where(delegator: staff_profile2).count).to eq(1)
      expect(Delegate.where(delegator: staff_profile2.supervisor).count).to eq(1)
      expect(Delegate.where(delegator: staff_profile2.department.head).count).to eq(1)
      expect(Delegate.where(delegate: staff_profile2.admin_assistants.first).count).to eq(3)
    end
  end
end
