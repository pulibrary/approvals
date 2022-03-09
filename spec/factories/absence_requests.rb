# frozen_string_literal: true

FactoryBot.define do
  factory :absence_request do
    creator { FactoryBot.create(:staff_profile, :with_supervisor) }
    start_date { Time.zone.today }
    end_date { Time.zone.tomorrow }
    hours_requested { 8 }
    transient do
      action { nil }
    end
    absence_type { "vacation" }

    after(:build) do |request, evaluator|
      fire_event_safely(request: request, action: evaluator.action, agent: request.creator.supervisor) if evaluator.action.present?
    end

    trait :with_note do
      notes { [FactoryBot.build(:note, creator: creator)] }

      after(:create) do |request, _evaluator|
        request.notes.first.request_id = request.id
        request.notes.first.save
      end
    end
  end
end
