require 'richcss'
require 'rest-client'
require 'json'
require 'pry'

module Richcss
  class Manager
    # Checks if the folder has the required format for uploading
    # Also a flag to check specifics for upload
    def self.check(part_name, upload)
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
      groups = ['box', 'elements']

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
        "authors" => "AUTHOR_NAME",
        "email" => "AUTHOR_EMAIL",
        "description" => "DESCRIPTION",
        "homepage" => "GITHUB_REPO_URL"
      }
      requiredSpecs = ['name', 'authors', 'email', 'description', 'version', 'homepage', 'dependencies']

      # Ensure each spec exist
      requiredSpecs.each do |spec|
        if hash[spec].nil?
          return "Missing \"#{spec}\" definition in #{specFile}"
        end
      end

      # Check for default entries
      defaultSpecs.keys.each do |spec|
        if hash[spec] == defaultSpecs[spec]
          return "Default value for \"#{spec}\" in #{specFile} is being used, please change it to a valid entry"
        end
      end

      # Check Part_Name
      if (hash[requiredSpecs[0]] != part_name)
        return "Invalid part name: \"#{hash[requiredSpecs[0]]}\" in #{specFile}, should be \"#{part_name}\""
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
              return "Could not access GitHub url, please use a public repository"
            end
          end
        end
      rescue
        return "Invalid Github url"
      end

      # Checks after this should only be used if we're doing upload
      if !upload
        return nil
      end

      # Check for version
      begin
	      resp = RestClient.get "http://localhost:3000/api/part/#{part_name}"
        if resp.code == 200
        	body = JSON.parse(resp.to_str)
        	current_version = body["version"]
        	part_version = hash[requiredSpecs[4]]
          if Gem::Version.new(current_version) >= Gem::Version.new(part_version)
          	return "Part version: \"#{part_version}\" in #{specFile} must be greater than existing version: \"#{current_version}\""
          end
        end
	    rescue RestClient::ExceptionWithResponse => e
      end

      # Check dependency existance
      dependencies = hash[requiredSpecs[6]];

      dependencies.keys.each do |name|
        expectedVersion = dependencies[name]
        # TODO: use server data
        # data = getPartData(name)
        data = ""
        if data.nil?
          return "Dependency part #{name} cannot be found in our database"
        end
      end

      return nil
    end

    # Fetch url and download the part
    def self.getPartData(part_name)
      begin
        resp = RestClient.get "http://localhost:3000/api/part/#{part_name}"
        if resp.code == 200
          body = JSON.parse(resp.to_str)
          return body
        else
          puts "Error: Part #{name} cannot be found."
        end
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end 
      return nil
    end

    def self.release(part_name)
    	specs = File.read("#{part_name}/#{part_name}.spec")
    	specsJson = JSON.parse(specs)

    	begin
	      puts RestClient.post "http://localhost:3000/api/upload", :name => part_name, :description => specsJson["description"],
	        :version => specsJson["version"], :authors => specsJson["authors"], :email => specsJson["email"], :homepage => specsJson["homepage"],
	        :dependencies => specsJson["dependencies"]
	    rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end 
    end
  end
end
