require 'thor'
require 'richcss'

module Richcss
  class CLI < Thor
    desc "init", "Initialize current directory to follow the Rich CSS framework"
    def init()
      Richcss::Richcss.init()
    end
  end
end