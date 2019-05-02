# frozen_string_literal: true

FactoryBot.define do
  factory :event_request do
    recurring_event { FactoryBot.create(:recurring_event) }
    start_date { Time.zone.now }
    end_date { Time.zone.tomorrow }
    location { "Location" }
    url { "www.example.com" }
  end
end
