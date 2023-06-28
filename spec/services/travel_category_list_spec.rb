# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelCategoryList do
  describe "valid_categories" do
    it "includes the categories specified in the travel policy" do
      expect(described_class.valid_categories).to contain_exactly(
        "acquisitions", "business", "conferences", "education_and_training",
        "professional_development", "required_business"
      )
    end
  end
end
