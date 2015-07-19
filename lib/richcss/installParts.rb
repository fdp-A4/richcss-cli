require 'thor/group'

module Richcss
  module InstallParts
    class Template < Thor::Group
      include Thor::Actions

      argument :parts, :type => :string

      def get_github_file
        put "retrieving parts from website"
        #gets file 
        url = ""
        install(url)
      end

      #install this part
      def install(url)
        Dir.chdir("parts") do
          system("wget -qO- -O tmp.zip #{url} && unzip tmp.zip && rm tmp.zip")
        end
      end
    end
  end
end