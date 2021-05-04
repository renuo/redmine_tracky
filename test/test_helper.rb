# frozen_string_literal: true

# Load the Redmine helper
require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")

require 'simplecov'
require File.expand_path(File.dirname(__FILE__) + "/coverage/html_formatter")
SimpleCov.formatter = Redmine::Coverage::HtmlFormatter
SimpleCov.start 'rails'
# TODO: uncomment after scaffold and setup => SimpleCov.minimum_coverage 100
