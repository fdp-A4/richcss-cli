require 'richcss'
require 'rest-client'
require 'json'

module Richcss
  class Manager
    # Checks if the current directory has the RichCSS folder format
    def self.check(part_name)
        # Check for root directory directory
        specFilePath = ''

        # LEVEL 1
        if !Dir.exist?(part_name)
            return "Part directory for [#{part_name}] does not exist"
        end

        # Search for spec file and readme
        foundReadme = false;
        foundSpec = false;
        Dir.foreach(part_name) do |filename|
            next if filename == '.' or filename == '..'
            if filename == "#{part_name.downcase}.spec"
                foundSpec = true
                specFilePath = "#{Dir.pwd}/#{part_name}/#{part_name.downcase}.spec"
            end
            if filename == "README.md"
                foundReadme = true
            end
        end

        if !foundSpec
            return "#{part_name.downcase}.spec file not found"
        end
        if !foundReadme
            return "README.md file not found"
        end

        # LIB CHECK
        Dir.chdir(part_name)

        if !Dir.exist?('lib')
            return "lib folder not found"
        end 

        # LEVEL 2 / LIB
        Dir.chdir('lib')
        groups = ['box', 'elements', 'parts']

        groups.each do |g|
            if !Dir.exist?(g)
                return "#{g} folder not found in lib"
            end
        end

        # LEVEL 3 BOX/ELEMENTS/PARTS
        # TODO: Don't do this hardcoded for box/elements, use like some hashmap or something..
        boxFiles = ['blocks', 'main', 'positioning'] 
        elementFiles = ['button', 'colors', 'features', 'fonts', 'images', 'inputs', 'lists']
        validExtensions = ['.css', '.css.scss']

        fileCount = 0
        Dir.foreach('box') do |filename|
            next if filename == '.' or filename == '..'
            boxFiles.each do |b|
                validExtensions.each do |ext|
                    if filename == "#{b}#{ext}"
                        fileCount += 1
                    end
                end
            end
        end

        if fileCount < boxFiles.size
            return "Missing css files in box folder, required #{boxFiles}"
        end

        fileCount = 0
        Dir.foreach('elements') do |filename|
            next if filename == '.' or filename == '..'
            elementFiles.each do |b|
                validExtensions.each do |ext|
                    if filename == "#{b}#{ext}"
                        fileCount += 1
                    end
                end
            end
        end

        if fileCount < elementFiles.size
            return "Missing css files in elements folder, required #{elementFiles}"
        end

        # SPEC FILE CHECK
        # jsonData = File.read("#{part_name}/#{part_name.downcase}.spec")
        specFile = "#{part_name.downcase}.spec"

        begin
            jsonData = File.read(specFilePath) 
            hash = JSON.parse(jsonData)
        rescue
            return "Invalid Json format in #{specFile}"  
        end
        
        defaultSpecs = {
            "author" => "AUTHOR_NAME",
            "email" => "AUTHOR_EMAIL",
            "description" => "DESCRIPTION",
            "github" => "GITHUB_REPO_URL"
        }
        requiredSpecs = ['part_name', 'author', 'email', 'description', 'version', 'github', 'dependencies']

        # Ensure each spec exist
        requiredSpecs.each do |spec|
            if hash[spec].nil?
                return "Missing #{spec} definition in #{specFile}"
            end
        end

        # Check for default entries
        defaultSpecs.keys.each do |spec|
            if hash[spec] == defaultSpecs[spec]
                return "Default value for #{spec} in #{specFile}"
            end
        end

        # Check Part_Name
        if (hash[requiredSpecs[0]] != part_name)
            return "Part name is invalid in #{specFile}"
        end

        # Check if github url exist
        uri = URI.parse(hash[requiredSpecs[5]])

        http_object = Net::HTTP.new(uri.host, uri.port)
        http_object.use_ssl = true if uri.scheme == 'https'
        begin
            http_object.start do |http|
              request = Net::HTTP::Get.new uri.request_uri
              http.read_timeout = 500
              http.request request do |response|
                case response
                when Net::HTTPNotFound then
                    return "Could not access GitHub url"
                end
              end
            end
        rescue
            return "Something has gone really wrong"
        end

        return nil
    end

    def self.release(part_name)
    	specs = File.read("#{part_name}/#{part_name}.spec")
    	specsJson = JSON.parse(specs)

    	begin
	      puts RestClient.post "http://localhost:3000/upload", :name => part_name, :description => specsJson["description"],
	        :version => specsJson["version"], :authors => specsJson["authors"], :email => specsJson["email"], :homepage => specsJson["homepage"],
	        :dependencies => specsJson["dependencies"]
	    rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end 
    end
  end
end
