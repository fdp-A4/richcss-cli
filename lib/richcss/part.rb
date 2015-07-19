require 'json'
require 'rest_client'

module Richcss
    class Part
      def download(part)
        put "retrieving parts from website"
        # TODO get download url
        url = ""
        install(url)
      end

      # Install this part
      def install(url)
        Dir.chdir("parts") do
          system("wget -qO- -O tmp.zip #{url} && unzip tmp.zip && rm tmp.zip")
        end
      end
    end
  end
end