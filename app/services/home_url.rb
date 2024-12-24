# frozen_string_literal: true

class HomeURL
  class << self
    def for(current_user:)
      return Rails.application.routes.url_helpers.root_path if current_user.blank?

      Rails.application.routes.url_helpers.my_requests_path
    end
  end
end
