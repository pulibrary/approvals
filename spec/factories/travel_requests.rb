# frozen_string_literal: true

FactoryBot.define do
  factory :travel_request do
    creator { FactoryBot.create(:staff_profile) }
    event_requests { [FactoryBot.build(:event_request)] }
    start_date { Time.zone.today }
    end_date { Time.zone.tomorrow }
    status { "pending" }

    trait :with_note_and_estimate do
      estimates { [FactoryBot.build(:estimate)] }
      notes { [FactoryBot.build(:note)] }

      after(:create) do |request, _evaluator|
        request.estimates.each do |estimate|
          estimate.request_id = request.id
          estimate.save
        end
      end
    end

    after(:create) do |request, _evaluator|
      if request.is_a? Request
        request.event_requests.first.request_id = request.id
        request.event_requests.first.save
      end
    end
  end
end
