PLUGIN_NAME = 'redmine_tracky'

guard 'rake', :task => "redmine:plugins:#{PLUGIN_NAME}:convert:sass" do
  watch(%r{plugins/redmine_tracky/assets/stylesheets/.+\.(css|scss)})
end
