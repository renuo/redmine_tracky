# frozen_string_literal: true

module RedmineTracky
  def self.root
    File.dirname(__FILE__, 2)
  end
end

%w[services].each do |folder|
  folder_path = File.dirname(__FILE__) + "/../app/#{folder}"
  ActiveSupport::Dependencies.autoload_paths += [folder_path]
end
