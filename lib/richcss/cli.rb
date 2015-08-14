require 'thor'
require 'richcss'

module Richcss
  class CLI < Thor
    desc "init", "Initialize current directory to follow the Rich CSS framework"
    def init()
      Richcss::Generators::Template.start(['box', 'elements', 'parts'])
    end

    desc "install PART", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def install(part_name)
      part = Richcss::Part.new
      part.name = part_name

    	part.fetch()
    end
  end
end
