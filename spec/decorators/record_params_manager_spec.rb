# frozen_string_literal: true
require "rails_helper"
RSpec.describe RecordsParamsManager, type: :model do
  subject(:records_params_decorator) { described_class.new({}) }
  let(:params_hash) { {} }

  describe "#build_url" do
    it "returns a record url" do
      expect(records_params_decorator.build_url({})).to eq("/records")
    end
  end

  describe "#current_sort" do
    it "is start date ascending" do
      expect(records_params_decorator.current_sort).to eq("start_date_asc")
    end
  end

  describe "#filter_params" do
    it "empty by default" do
      expect(records_params_decorator.filter_params).to eq({})
    end
  end
end
