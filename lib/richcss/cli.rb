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
    # |    |--- parts
    # |    |    |--- ...
    # |--- part_name.spec
    # |--- README.md
    def init(part)
      Richcss::Generators::Template.start([part])
    end

    desc "install <PART>", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def install(part_name)
    	Richcss::Part.fetch(part_name)
    end

    desc "push <PART_NAME>", "Attempt to upload a new Rich CSS part to our servers"
    def push(part_name)
      Richcss::Manager.release(part_name)
    end

    desc "Check format", "yep"
    def check(part_name)
      result = Richcss::Manager.check(part_name, true)
      if result.nil?
        puts "Successed"
      else
        puts result
      end
    end

    desc "testdependencyresolution", "Test the dependency resolver where the result should be a succesful resolution"
    def testdependencyresolution()
      Richcss::Resolver.resolveTest()
    end
  end
end
