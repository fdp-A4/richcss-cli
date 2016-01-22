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

    desc "install <PART>", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def install(part_name)
        dep_list = Richcss::Part.resolve_dependencies(part_name)
        dep_list.each do |dep|
          Richcss::Part.fetch(dep.name, dep.version)
        end
        Richcss::Part.fetch(part_name)
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

    desc "push <PART_NAME>", "Attempt to upload a new Rich CSS part to our servers"
    def push(part_name)
      if check(part_name)
        Richcss::Manager.upload(part_name)
      end
    end

    desc "testdependencyresolution", "Test the dependency resolver where the result should be a succesful resolution"
    def testdependencyresolution()
      Richcss::Resolver.resolveTest()
    end
  end
end
