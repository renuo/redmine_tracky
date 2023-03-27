# frozen_string_literal: true

REDMINE_URL = 'http://localhost:3000'
MAILHOG_URL = 'http://localhost:8025'

desc "SSH into a service. Defaults to 'redmine'."
task :ssh do
  rails_env = ENV.fetch('RAILS_ENV', 'development')
  service = ENV.fetch('SERVICE', 'redmine')

  sh "docker compose exec -e RAILS_ENV=#{rails_env} #{service} bash"
end

desc 'Execute a Rails command'
task :rails do |_t, args|
  sh "docker compose exec redmine rails #{args.extras.join(' ')}"
end

desc 'Launch MySQL'
task :mysql do |_t, args|
  args.with_defaults(
    user: 'root',
    pass: 'root',
    rails_env: ENV.fetch('RAILS_ENV', 'development')
  )
  sh "docker compose exec mysql mysql -u#{args.user} -p#{args.pass} redmine_#{args.rails_env}"
end

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
    sh "docker compose exec -e RAILS_ENV=#{rails_env} redmine rake #{command}"
  end

  puts "The env '#{rails_env}' has been reset."
end

desc 'Install dependencies.'
task :install_dependencies do
  puts 'Installing dev packages...'
  sh 'docker compose exec redmine bundle install'
end

desc 'Provision the environment.'
task :provision do
  Rake::Task[:install_dependencies].invoke

  puts 'Preparing database...'
  sh 'docker compose exec redmine rake db:seed'

  puts <<~RESULT
    ======
    Redmine is ready!
    ======
  RESULT

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

desc 'Lint all code.'
task :lint do
  Rake::Task['lint_ruby'].execute
  Rake::Task['lint_javascript'].execute
end

desc 'Lint Ruby code.'
task :lint_ruby do
  sh 'docker compose exec redmine rubocop -c plugins/redmine_tracky/.rubocop.yml plugins/redmine_tracky'
end

desc 'Format Ruby code.'
task :format do
  sh 'docker compose exec redmine rubocop -c plugins/redmine_tracky/.rubocop.yml plugins/redmine_tracky -A'
end

desc 'Test all code.'
task :test do
  Rake::Task['test_ruby'].execute
  Rake::Task['test_javascript'].execute
end

desc 'Test Ruby code.'
task :test_ruby do
  file = ENV.fetch('TEST', nil)
  type = ENV.fetch('TYPE', nil)
  type = type ? ":#{type}" : nil

  command =
    if file
      "test TEST=plugins/redmine_tracky/#{file}"
    else
      "redmine:plugins:test#{type} NAME=redmine_tracky"
    end

  sh "docker compose exec -e RAILS_ENV=test redmine rake #{command}"
end

desc 'Test JavaScript code.'
task :test_javascript do
  sh 'docker compose exec -w /app/assets.src node npm run test'
end

desc 'Watch and compile CSS and JS assets.'
task :watch do
  sh 'docker compose exec -w /app/assets.src node npm run watch'
end
