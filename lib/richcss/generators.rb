require 'thor/group'

module Richcss
  module Generators
    class Template < Thor::Group
      include Thor::Actions

      argument :groups, :type => :array

      def self.source_root
        File.dirname(__FILE__) + "/generator"
      end

      def create_routes
        copy_file "routes.scss", "routes.scss"
      end
      
      def create_group
        groups.each { |g| empty_directory(g) }
      end

      def create_keepfile
        groups.each { |g| create_file "#{g}/.keep" }
      end
    end
  end
end
