require 'thor/group'

module Richcss
  module Generators
    class Template < Thor::Group
      include Thor::Actions

      argument :group, :type => :string

      def create_group
        empty_directory(group)
      end

      def create_keepfile
        create_file "#{group}/.keep"
      end
    end
  end
end