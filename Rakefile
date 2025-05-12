# frozen_string_literal: true

REDMINE_URL = 'http://localhost:3000'
MAILHOG_URL = 'http://localhost:8025'

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

  commands.each do |command|
    sh "cd ../.. && RAILS_ENV=#{rails_env} rake #{command}"
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
  sh 'cd ../.. && rails s'
end

desc 'Lint all code.'
task :lint do
  Rake::Task['lint_ruby'].execute
  Rake::Task['lint_javascript'].execute
end

desc 'Lint Ruby code.'
task :lint_ruby do
  sh "bundle exec rubocop #{'-f g' if ENV.key?('GITHUB_ACTIONS')} -c .rubocop.yml"
  sh 'bundle exec brakeman -q -z --no-summary --no-pager'
end

desc 'Format Ruby code.'
task :format do
  sh 'bundle exec rubocop -c .rubocop.yml . -A'
end

desc 'Lint JavaScript code.'
task :lint_javascript do
  sh 'cd assets.src && npm run lint'
end

desc 'Test all code.'
task :test do
  Rake::Task['test_ruby'].execute
  Rake::Task['test_javascript'].execute
end

desc 'Test Ruby code.'
task :test_ruby do
  file = ENV.fetch('TEST', nil)
  file = "test/#{file}" if file
  sh "cd ../.. && RAILS_ENV=test rake test TEST=plugins/redmine_tracky/#{file}"
end

desc 'Test JavaScript code.'
task :test_javascript do
  # TODO: sh 'cd assets.src && npm run test'
end

desc 'Compile CSS and JS assets.'
task :build do
  sh 'cd assets.src && npm run build'
end

desc 'Watch and compile CSS and JS assets.'
task :watch do
  sh 'cd assets.src && npm run watch'
end
