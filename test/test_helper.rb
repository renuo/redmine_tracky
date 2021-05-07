# frozen_string_literal: true

# Load the Redmine helper

require 'simplecov'
require 'factory_bot_rails'

if Dir.pwd.match(/plugins\/redmine_tracky/)
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
else
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])
end

SimpleCov.coverage_dir('coverage/redmine_tracky')
SimpleCov.start 'rails' do
  add_filter do |source_file|
    !source_file.filename.include?('plugins/redmine_tracky') || !source_file.filename.end_with?('.rb')
  end
end

# SimpleCov.minimum_coverage 100
FactoryBot.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryBot.find_definitions

require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

class ActionController::TestCase
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods
end
