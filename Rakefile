# frozen_string_literal: true

REDMINE_URL = 'http://localhost:3000'
MAILHOG_URL = 'http://localhost:8025'
REDMINE_ROOT = File.expand_path('tmp/redmine', __dir__)

ENV['BUNDLE_GEMFILE'] ||= File.join(REDMINE_ROOT, 'Gemfile')

desc 'Reset the database.'
task :reset do
  rails_env = ENV.fetch('RAILS_ENV') do
    abort('Env var RAILS_ENV cannot be empty')
  end

  commands = [
    'db:drop',
    'db:create',
    'db:migrate',
    'redmine:plugins:migrate'
  ]

  commands << 'db:seed' if rails_env == 'development'

  rm_f File.join(REDMINE_ROOT, 'db/schema.rb')
  commands.each do |command|
    sh "cd #{REDMINE_ROOT} && RAILS_ENV=#{rails_env} bin/rails #{command}"
  end

  puts "The env '#{rails_env}' has been reset."
end

desc 'Setup Tracky.'
task :setup do
  puts 'Setting up tracky...'
  sh 'bin/setup'

  Rake::Task[:info].invoke
end

desc 'Dev env info.'
task :info do
  puts <<~INFO
    USERS
    ----------------------------------------------------
    Login  | Email address      | Password
    ----------------------------------------------------
    admin  | admin@example.com  | admin
    jsmith | jsmith@example.com | jsmith
    ----------------------------------------------------

    URLS
    ----------------------------------------------------
    Redmine         | #{REDMINE_URL}/
    Redmine Tracky  | #{REDMINE_URL}/tracky
    Mailhog         | #{MAILHOG_URL}/
    ----------------------------------------------------
  INFO
end

desc 'Run code.'
task :run do
  sh "cd #{REDMINE_ROOT} && bin/rails server"
end

desc 'Lint all code.'
task :lint do
  sh "bundle exec rubocop #{'-f g' if ENV.key?('GITHUB_ACTIONS')} -c .rubocop.yml"
  sh 'bundle exec brakeman -q -z --no-summary --no-pager'
end

desc 'Format Ruby code.'
task :format do
  sh 'bundle exec rubocop -c .rubocop.yml . -A'
end

desc 'Test all code.'
task :test do
  sh "cd #{REDMINE_ROOT} && RAILS_ENV=test bin/rails test plugins/redmine_tracky/test/#{ENV.fetch('TEST', nil)}"
end

desc 'Test Redmine with Tracky installed.'
task :test_redmine do
  sh "cd #{REDMINE_ROOT} && RAILS_ENV=test bin/rails test"
end
