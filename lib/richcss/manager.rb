require 'richcss'
require 'rest-client'
require 'pry'

module Richcss
  class Manager
    # Checks if the current directory has the RichCSS folder format
    def self.check()
    end

    def self.release(part_name)
    	specs = File.read("#{part_name}/#{part_name}.spec")
    	specsJson = JSON.parse(specs)

    	# binding.pry

      resp = RestClient.post "http://localhost:3000/upload", :name => part_name, :description => specsJson["description"],
        :version => specsJson["version"], :authors => specsJson["authors"], :email => specsJson["email"], :homepage => specsJson["homepage"],
        :dependencies => specsJson["dependencies"]
      body = JSON.parse(resp)

      if body.code == 200 
      	puts body["success"]
      else
      	puts body["error"]
      end
    end
  end
end
