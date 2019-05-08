# frozen_string_literal: true

FactoryBot.define do
  factory :absence_request do
    creator { FactoryBot.create(:staff_profile) }
    start_date { Time.zone.today }
    end_date { Time.zone.tomorrow }
    status { "pending" }

    trait :with_note do
      notes { [FactoryBot.build(:note)] }

      after(:create) do |request, _evaluator|
        request.notes.first.request_id = request.id
        request.notes.first.save
      end
    end
  end
end
