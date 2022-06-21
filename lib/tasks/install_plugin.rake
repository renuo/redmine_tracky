# frozen_string_literal: true

require 'fileutils'

PLUGIN_NAME = 'redmine_tracky'
LINE_SEPARATOR_LENGTH = 60

namespace :redmine do
  namespace :plugins do
    namespace :"#{PLUGIN_NAME}" do
      @plugin = PLUGIN_NAME

      task :install do
        Rake::Task['redmine:plugins:migrate'].invoke
      end
    end
  end
end
