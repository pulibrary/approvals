# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    creator { FactoryBot.create(:staff_profile) }
    event_requests { [FactoryBot.build(:event_request)] }

    after(:create) do |request, _evaluator|
      if request.is_a? Request
        request.event_requests.first.request_id = request.id
        request.event_requests.first.save
      end
    end
  end
end
