# frozen_string_literal: true
require "rails_helper"

RSpec.describe Department, type: :model do
  describe "attributes" do
    subject(:department) { described_class.new }
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :number }
    it { is_expected.to respond_to :head_id }
    it { is_expected.to respond_to :admin_assistant_ids }
    it { is_expected.to respond_to :head }
    it { is_expected.to respond_to :admin_assistants }
  end

  describe "#destory" do
    it "destroys dependants" do
      department = FactoryBot.create(:department)
      aa = FactoryBot.create(:staff_profile)
      department.admin_assistants << aa
      department.save
      expect { department.destroy }.to change(AdminAssistantsDepartment, :count).by(-1)
    end
  end
end
