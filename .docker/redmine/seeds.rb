require 'active_record/fixtures'

lambda {
  # For DEVELOPMENT use only.
  return unless Rails.env.development?

  fixture_directory = File.join(RedmineTracky.root, 'test', 'fixtures')
  fixture_set_names = Dir[File.join(fixture_directory, '*.yml')].map do |f|
    File.basename(f, '.yml')
  end

  load(File.join(RedmineTracky.root, 'db', 'sample_data.rb'))

  ActiveRecord::FixtureSet.create_fixtures(
    fixture_directory,
    fixture_set_names
  )
}.call
