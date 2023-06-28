# frozen_string_literal: true
class TravelCategoryList
  def self.categories
    current_categories + deprecated_categories
  end

  def self.current_categories
    %w[acquisitions conferences education_and_training required_business]
  end

  def self.deprecated_categories
    %w[business professional_development]
  end
end
