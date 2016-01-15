require 'thor/group'
require 'json'

module Richcss
  module Generators
    class Template < Thor::Group
      include Thor::Actions

      argument :part_name, :type => :array
      # argument :part, :type => :array
      # argument :part_name, :type => :string

      def self.source_root
        File.dirname(__FILE__) + "/generator"
      end

      def init
        @name = part_name.first
        @groups = ['box', 'elements', 'parts']
      end

      def create_folders
        empty_directory(@name)
        empty_directory("#{@name}/lib")
        @groups.each { |g| empty_directory("#{@name}/lib/#{g}") }
      end

      def create_files
        create_file "#{@name}/README.md"
        create_file "#{@name}/#{@name.downcase}.spec"
        # Write JSON to Test.Spec
        specs = {
          "name" => "#{@name}",
          "authors" => "AUTHOR_NAME",
          "email" => "AUTHOR_EMAIL",
          "description" => "DESCRIPTION",
          "version" => "0.0.0",
          "homepage" => "GITHUB_REPO_URL",
          "dependencies" => { 
            "DEPENDECY_NAME" => "DEPENDECY_VERSION" 
          }
        }
        File.open("#{@name}/#{@name.downcase}.spec","w") do |f|
          f.write(JSON.pretty_generate(specs))
        end
      end
    end
  end
end
