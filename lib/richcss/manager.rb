require 'richcss'
require 'rest-client'
require 'json'
require 'active_model'
require 'email_validator'

module Richcss
  class Manager
    # Checks if the folder has the required format for uploading
    def self.check(check_dir)
      Dir.chdir(check_dir)

      # LEVEL 1
      # Find the spec file and the part name
      part_name = ''
      specFilePath = ''
      Dir.glob("*.spec").each do |f|
        part_name = File.basename(f, '.spec')
        specFilePath = "#{check_dir}/#{f}"
      end
      if part_name.empty?
        return "Rich CSS spec file not found"
      end

      # Check if readme exists
      if !File.file?("#{check_dir}/README.md")
        return "README.md file not found"
      end

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
      specFile = "#{part_name}.spec"

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
        if hash[spec].nil? && spec != 'dependencies'
          return "Missing \"#{spec}\" definition in #{specFile}"
        end
      end

      # Check for default entries
      defaultSpecs.keys.each do |spec|
        if hash[spec] == defaultSpecs[spec]
          return "Default value for \"#{spec}\" in #{specFile} is being used, please change it to a valid entry"
        end
      end

      # Check email
      if !EmailValidator.valid?(hash[requiredSpecs[2]])
        return "Email address is invalid"
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
        return "Invalid URL for homepage"
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
      dependencies = hash[requiredSpecs[6]]
      if dependencies.nil?
        return nil
      end

      begin
      	dependencies = dependencies.to_a.map { |x| "#{x[0]}=#{x[1].to_s}" }.join("&")
        resp = RestClient.get "http://localhost:3000/api/validateDependencies/#{dependencies}"
      rescue RestClient::ExceptionWithResponse => e
        return e.response
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

    def self.upload(part_path)
      partPathSplit = part_path.split("/")
      partName = partPathSplit[partPathSplit.length - 1]

      if !File.file?("#{part_path}/#{partName}.spec")
        puts "#{part_path}/#{partName}.spec file not found"
        return
      end

      specs = File.read("#{part_path}/#{partName}.spec")
      specsJson = JSON.parse(specs)

      begin
	    puts RestClient.post "http://localhost:3000/api/upload", :name => partName, :description => specsJson["description"],
	      :version => specsJson["version"], :authors => specsJson["authors"], :email => specsJson["email"], :homepage => specsJson["homepage"],
	      :dependencies => specsJson["dependencies"]
	  rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end 
    end

  end
end
