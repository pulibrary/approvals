class RequestsEventInstances < ApplicationRecord
  belongs_to :request
  belongs_to :event_instance
end
