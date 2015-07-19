require 'thor'
require 'richcss'
require 'installParts'

module Richcss
  class CLI < Thor
    desc "init", "Initialize current directory to follow the Rich CSS framework"
    def init()
      Richcss::Richcss.init()
    end

    desc "install PARTS", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def installParts(parts)
    	Richcss::installParts.get_github_file(parts)
    end
  end
end