# frozen_string_literal: true
require "rails_helper"

RSpec.describe TravelCategoryList do
  describe "categories" do
    it "includes both current and historical categories" do
      expect(described_class.categories).to contain_exactly(
        "acquisitions", "business", "conferences", "education_and_training",
        "professional_development", "required_business"
      )
    end
  end
end
