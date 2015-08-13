require 'json'
require 'rest-client'

module Richcss
  class Part
    attr_accessor :name

    # Fetch url and download the part
    def fetch()
      begin
        resp = RestClient.get 'localhost:3000/api/part', {:params => {'name' => name}}
        
        if resp.code == 200
          body = JSON.parse(resp.to_str)
          self.install(body['url'])
        else
          puts "Error: Part " + name + " cannot be found."
        end
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end

    # Install this part
    def install(url)
      Dir.chdir("parts") do
        # TODO
        system("wget -qO- -O tmp.zip #{url} && unzip tmp.zip && rm tmp.zip")
      end
    end
  end
end