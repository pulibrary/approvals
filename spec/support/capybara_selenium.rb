# frozen_string_literal: true
require "capybara/rails"
require "selenium-webdriver"
require "capybara/rspec"
require "capybara-screenshot/rspec"

Capybara.server = :puma, { Silent: true }

Capybara.register_driver(:selenium) do |app|

  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--headless" unless ENV["RUN_IN_BROWSER"] == "true"
  browser_options.args << "--disable-gpu"
  browser_options.args << "--disable-setuid-sandbox"
  browser_options.args << "--window-size=7680,4320"

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120

  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 http_client:,
                                 options: browser_options)
end

Capybara.javascript_driver = :selenium
