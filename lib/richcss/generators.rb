require 'thor/group'
require 'json'

module Richcss
  module Generators
    class Template < Thor::Group
      include Thor::Actions
      
      # Args is [extension]
      argument :arguments, :type => :array

      def self.source_root
        File.dirname(__FILE__) + "/generator"
      end

      def init
        @groups = ['box', 'elements', 'parts']
        @boxFiles = ['blocks', 'main', 'positioning']
        @elementFiles = ['button', 'colors', 'features', 'fonts', 'images', 'inputs', 'lists']
        @partFiles = ['Partfile']
        @extension = "." + arguments[0];
      end

      def create_folders
        @groups.each do |g|
          empty_directory("#{g}") unless Dir.exists?("#{g}")
        end
      end

      def create_css_files
        @boxFiles.each do |filename|
          create_file "box/#{filename}#{@extension}" unless File.file?("box/#{filename}#{@extension}")
        end 

        @elementFiles.each do |filename|
          create_file "elements/#{filename}#{@extension}" unless File.file?("elements/#{filename}#{@extension}")
        end
      end
      
      def create_partfile
        create_file "parts/Partfile" unless File.file?("parts/Partfile")
      end
    end

    class PartTemplate < Thor::Group
      include Thor::Actions

      # Args is [part_name, extension]
      argument :arguments, :type => :array


      # argument :part, :type => :array
      # argument :part_name, :type => :string

      def self.source_root
        File.dirname(__FILE__) + "/generator"
      end

      def init
        @name = arguments[0]
        @groups = ['box', 'elements']
        @boxFiles = ['blocks', 'main', 'positioning']
        @elementFiles = ['button', 'colors', 'features', 'fonts', 'images', 'inputs', 'lists']
        @extension = "." + arguments[1];
      end

      def create_folders
        empty_directory(@name) unless Dir.exists?(@name)
        empty_directory("#{@name}/lib") unless Dir.exists?("#{@name}/lib")
        @groups.each do |g| 
          empty_directory("#{@name}/lib/#{g}") unless Dir.exists?("#{@name}/lib/#{g}")
        end
      end

      def create_css_files
        @boxFiles.each do |filename|
          create_file "#{@name}/lib/box/#{filename}#{@extension}" unless File.file?("#{@name}/lib/box/#{filename}#{@extension}")
        end 

        @elementFiles.each do |filename|
          create_file "#{@name}/lib/elements/#{filename}#{@extension}" unless File.file?("#{@name}/lib/elements/#{filename}#{@extension}")
        end
      end

      def create_files
        create_file "#{@name}/README.md" unless File.file?("#{@name}/README.md")

        if !File.file?("#{@name}/#{@name.downcase}.spec")
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
end
