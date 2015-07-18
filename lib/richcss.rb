require "richcss/version"

module Richcss
  class Richcss
    def init()
      Richcss::Generators::Template.start('box')
      Richcss::Generators::Template.start('elements')
      Richcss::Generators::Template.start('parts')
    end
end
