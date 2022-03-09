# frozen_string_literal: true

FactoryBot.define do
  factory :travel_request do
    creator { FactoryBot.create(:staff_profile, :with_department) }
    start_date { Time.zone.today }
    end_date { Time.zone.tomorrow }
    event_requests { [FactoryBot.build(:event_request, start_date: start_date, end_date: end_date)] }
    purpose { "My grand purpose" }
    participation { "other" }
    transient do
      action { nil }
    end

    after(:build) do |request, evaluator|
      fire_event_safely(request: request, action: evaluator.action, agent: request.creator.department.head) if evaluator.action.present?
    end

    trait :with_note_and_estimate do
      estimates { [FactoryBot.build(:estimate)] }
      notes { [FactoryBot.build(:note, creator: creator)] }

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
