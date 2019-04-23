# frozen_string_literal: true

# Main class for the application models to inherit from
#   Utilize this class if your want to make global changes to all models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
