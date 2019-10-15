# frozen_string_literal: true

require "simplecov"

class SimpleCovHelper
  def self.report_coverage(base_dir: "./coverage")
    SimpleCov.configure do
      minimum_coverage(98)
    end
    new(base_dir: base_dir).inspect_results
  end

  attr_reader :base_dir

  def initialize(base_dir:)
    @base_dir = base_dir
  end

  def results_file
    Pathname "#{base_dir}/.resultset.json"
  end

  def inspect_results
    results = SimpleCov::Result.from_hash(JSON.parse(File.read(results_file)))
    results.format!
    covered_percent = results.covered_percent.round(2)
    return unless covered_percent < SimpleCov.minimum_coverage
    $stderr.printf("Coverage (%.2f%%) is below the expected minimum coverage (%.2f%%).\n", covered_percent, SimpleCov.minimum_coverage)
    Kernel.exit SimpleCov::ExitCodes::MINIMUM_COVERAGE
  end
end

SimpleCovHelper.report_coverage
