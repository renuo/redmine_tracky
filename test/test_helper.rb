# frozen_string_literal: true

# Load the Redmine helper
require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")

require 'simplecov'

if Dir.pwd.match(/plugins\/redmine_tracky/)
  covdir = 'coverage'
else
  covdir = 'plugins/redmine_tracky/coverage'
end

SimpleCov.coverage_dir(covdir)
SimpleCov.start 'rails' do
  add_filter do |source_file|
    # only show files belonging to planner, except init.rb which is not fully testable
    source_file.filename.match(/redmine_tracky/).nil? ||
      !source_file.filename.match(/redmine_tracky\/init.rb/).nil?
  end
end

SimpleCov.minimum_coverage 100
