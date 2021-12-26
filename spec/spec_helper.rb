require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  # minimum_coverage line: 90
  # minimum_coverage_by_file 80

  coverage_dir 'tmp/coverage'
  formatter SimpleCov::Formatter::HTMLFormatter
  if ENV['CI']
    command_name "#{ENV['CI_JOB_NAME']} on branch #{ENV['CI_COMMIT_REF_NAME']}"
    require 'simplecov-cobertura'
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::CoberturaFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ])
  end

  #track_files 'app/**/*.rb'
  add_filter '/bin/'
  add_filter '/exe/'
  add_filter '/pkg/'
  add_filter '/spec/'
  add_filter '/tmp/'
  add_filter '/vendor/'
end if ENV['COVERAGE']

SimpleCov.at_exit do
  # Still run configured formatter.
  SimpleCov.result.format!

  # Write the coverage percentage to a file for CI.
  total_path = File.join(SimpleCov.coverage_path, 'total.txt')
  cov_percent = SimpleCov.result.files.covered_percent.round(2)
  File.write(total_path, cov_percent)
  puts "Coverage percent (#{cov_percent}%) written to #{total_path}."
end if ENV['COVERAGE']

require 'bundler/setup'
require 'gollum_search'
require 'rack/test'

RSpec.configure do |config|

  config.include Rack::Test::Methods

  def app
    GollumSearch::Middleware
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
