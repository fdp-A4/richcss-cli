require 'thor'
require 'richcss'

module Richcss
  class CLI < Thor
    desc "init <PART_NAME>", "Initialize current directory to follow the Rich CSS framework"

    # part_name
    # |--- lib
    # |    |--- elements
    # |    |    |--- ...
    # |    |--- box
    # |    |    |--- ...
    # |--- part_name.spec
    # |--- README.md
    def init(part)
      Richcss::Generators::Template.start([part])
    end

    desc "install <PART> [VERSION]", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def install(part_name, part_version='')
        dep_list = Richcss::Part.resolve_dependencies(part_name, part_version)
        dep_list.each do |dep|
          Richcss::Part.fetch(dep.name, dep.version)
        end
    end

    desc "check <PART_NAME>", "Check to make sure that the CSS Part is following the folder/file structure and validating the spec file values"
    def check(part_name)
      root_dir = Dir.pwd
      result = Richcss::Manager.check(part_name)
      Dir.chdir(root_dir)
      if !result.nil?
        puts result
        return false
      end

      puts "Passed all validation checks, part: #{part_name} is ready for upload!"
      return true
    end

    desc "push <PART_PATH>", "Attempt to upload a new Rich CSS part to our servers"
    def push(part_path)
      if check(part_path)
        Richcss::Manager.upload(part_path)
      end
    end

  end
end
