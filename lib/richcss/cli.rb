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
      # Richcss::Generators::Template.start('abc')
    end

    desc "install <PART>", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def install(part_name)
      part = Richcss::Part.new
      part.name = part_name

    	part.fetch()
    end

    desc "push <PART_NAME>", "Attempt to upload a new Rich CSS part to our servers"
    def push(part_name)
      Richcss::Manager.release(part_name)
    end

    desc "Check format", "yep"
    def check(part_name)
      result = Richcss::Manager.check(part_name)
      if result.nil?
        puts "Successed"
      else
        puts result
      end
    end
  end
end
