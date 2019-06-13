# frozen_string_literal: true
require "capybara/rspec"
require "selenium-webdriver"
require "capybara-screenshot/rspec"

Capybara.server = :puma, { Silent: true }
Capybara.register_driver(:selenium) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu disable-setuid-sandbox window-size=7680,4320] }
  )
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities)
end

Capybara.javascript_driver = :selenium
