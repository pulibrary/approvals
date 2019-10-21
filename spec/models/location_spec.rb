# frozen_string_literal: true
require "rails_helper"

RSpec.describe Location, type: :model do
  subject(:location) { described_class.new }
  it { is_expected.to respond_to :building }
  it { is_expected.to respond_to :admin_assistant_id }
  it { is_expected.to respond_to :admin_assistant }
end
