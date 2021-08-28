require 'fileutils'

PLUGIN_NAME = 'redmine_tracky'
LINE_SEPARATOR_LENGTH = 60

namespace :redmine do
  namespace :plugins do
    namespace :"#{PLUGIN_NAME}" do
      @plugin = PLUGIN_NAME

      task :install do
        Rake::Task["redmine:plugins:migrate"].invoke
        Rake::Task["redmine:plugins:#{PLUGIN_NAME}:convert:sass"].invoke
      end

      desc "Copy Guard file to redmine root"
      task :setup do
        guardfile = File.read(Rails.root.join("plugins/#{@plugin}/Guardfile"))
        if File.exists? 'Guardfile'
          puts "A Guardfile alread exists in your Rails root. Please add the following blocks to your Guardfile in order to watch sass files:"
          puts 
          puts '-'*LINE_SEPARATOR_LENGTH
          puts guardfile
          puts '-'*LINE_SEPARATOR_LENGTH
          puts
        else
          File.open(Rails.root.join('Guardfile'), 'w') { |file| file.write(guardfile)}
          puts "A Guardfile has been written to #{Rails.root}."
        end
      end

      namespace :convert do
        task :sass do
          puts "Compiling sass files:"
          puts '---'

          source_dir = Rails.root.join("plugins/#{@plugin}/assets/stylesheets")
          dest_dir = Rails.root.join("public/plugin_assets/#{@plugin}/stylesheets")

          directories = Dir.glob(source_dir.join('**/*')).select {|fn| File.directory? fn }
          directories << source_dir
          directories.each do |sass_dir|
            Dir.glob("#{sass_dir}/*.scss").each do |sass_file|
              sass_filename = File.basename sass_file
              css_filename = sass_filename.sub('.scss', '')

              rel_css_dir = sass_dir.sub(source_dir.to_path, '')        
              css_dir = [dest_dir, rel_css_dir].join('')

              css_content = Sass.compile File.read(sass_file)
              FileUtils.mkdir_p(css_dir)
              css_file = [[css_dir, css_filename].join('/'), 'css'].join('.')
              File.open(css_file, 'w') { |file| file.write(css_content) }

              puts "FROM: #{sass_file}"
              puts "TO: #{css_file}"
              puts '---'
            end
          end
        end
      end
    end
  end
end
