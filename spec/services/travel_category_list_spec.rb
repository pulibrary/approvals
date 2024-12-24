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

  describe "human_readable_categories" do
    it "includes the humanized category name as the value" do
      expect(described_class.human_readable_categories).to include(
        "conferences" => "Conferences"
      )
    end

    it "indicates when a category is deprecated" do
      expect(described_class.human_readable_categories).to include(
        "business" => "Business (deprecated)"
      )
    end
  end
end
