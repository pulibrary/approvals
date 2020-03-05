# frozen_string_literal: true
require "rails_helper"
RSpec.describe RecordListDecorator, type: :model do
  subject(:record_list_decorator) { described_class.new([FactoryBot.create(:absence_request)], params_hash: params_hash, params_manager_class: RecordsParamsManager) }
  let(:params_hash) { {} }

  describe "attributes relevant to list" do
    it { is_expected.to respond_to :each }
    it { is_expected.to respond_to :to_a }
    it { is_expected.to respond_to :map }
    it { is_expected.to respond_to :count }
    it { is_expected.to respond_to :first }
    it { is_expected.to respond_to :last }
  end

  describe "#request_type_filters" do
    it "returns a list of Request type filter for absenc only" do
      expect(record_list_decorator.request_type_filters).to eq("Absence" => { children:
                                                                              {
                                                                                "Consulting" => "/records?filters%5Brequest_type%5D=consulting",
                                                                                "Death in family" => "/records?filters%5Brequest_type%5D=death_in_family",
                                                                                "Jury duty" => "/records?filters%5Brequest_type%5D=jury_duty",
                                                                                "Personal" => "/records?filters%5Brequest_type%5D=personal",
                                                                                "Research days" => "/records?filters%5Brequest_type%5D=research_days",
                                                                                "Sick" => "/records?filters%5Brequest_type%5D=sick",
                                                                                "Vacation" => "/records?filters%5Brequest_type%5D=vacation"
                                                                              },
                                                                              url: "/records?filters%5Brequest_type%5D=absence" })
    end
  end
end
