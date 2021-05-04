# frozen_string_literal: true

%w[services].each do |folder|
  folder_path = File.dirname(__FILE__) + "/../app/#{folder}"
  ActiveSupport::Dependencies.autoload_path += [folder_path]
end
