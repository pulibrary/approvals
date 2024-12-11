# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /health" do
    it "has a health check" do
      get "/health.json"
      expect(response).to be_successful
    end

    it "errors when there's a failure to a critical service" do
      allow_any_instance_of(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).to receive(:execute) do |instance|
        raise StandardError if database.blank? || instance.pool.db_config.name == database.to_s
      end

      get "/health.json"

      expect(response).not_to be_successful
      expect(response).to have_http_status :service_unavailable
    end
  end
end