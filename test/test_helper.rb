# frozen_string_literal: true

# Load the Redmine helper

require 'simplecov'
require 'factory_bot_rails'
require 'minitest/reporters'

ENV['GOOGLE_CHROME_OPTS_ARGS'] = 'headless,disable-gpu,no-sandbox,disable-dev-shm-usage'

if ENV['CI'] || ENV['GITHUB_ACTIONS']
  Minitest::Reporters.use! [
    Minitest::Reporters::DefaultReporter.new,
    Minitest::Reporters::JUnitReporter.new
  ]
else
  Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
end

SimpleCov.coverage_dir('coverage/redmine_tracky')
SimpleCov.start 'rails' do
  if Dir.pwd.match?(%r{plugins/redmine_tracky})
    formatter SimpleCov::Formatter::SimpleFormatter
  else
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::SimpleFormatter,
                                                         SimpleCov::Formatter::HTMLFormatter
                                                       ])
  end

  add_filter do |source_file|
    source_file.filename.exclude?('plugins/redmine_tracky') || !source_file.filename.end_with?('.rb')
  end

  track_files 'app/**/*.rb'

  enable_coverage :branch
  minimum_coverage line: 95, branch: 70
end

FactoryBot.definition_file_paths = [File.expand_path('factories', __dir__)]
FactoryBot.find_definitions

require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
  end
end

module ActionController
  class TestCase
    include FactoryBot::Syntax::Methods
  end
end

module ActionDispatch
  class IntegrationTest
    include FactoryBot::Syntax::Methods
  end
end
