require 'thor'
require 'richcss'

module RichcssCLI
  class Part < Thor
    desc "init <PART_NAME> [css/scss]", "Generate a skeleton directory for your new Rich CSS part, either css or scss files"
    # part_name
    # |--- lib
    # |    |--- elements
    # |    |    |--- ...
    # |    |--- box
    # |    |    |--- ...
    # |--- part_name.spec
    # |--- README.md
    def init(part, extension="css")
      if (extension.eql?("css") || extension.eql?("scss"))
        Richcss::Generators::PartTemplate.start([part, extension])
      else
        puts "Only support css or scss extension, default is css"
      end
    end

    desc "check [PART_PATH]", "Validate folder/file structure of the Rich CSS part, optionally passing in a path"
    def check(part_dir_name=nil)
      part_path = "#{Dir.pwd}" + "/" + "#{part_dir_name}" || Dir.pwd
      result = Richcss::Manager.check(part_path)
      Dir.chdir(part_path)
      if !result.nil?
        puts result
        return false
      end

      partPathSplit = part_path.split("/")
      partName = partPathSplit[partPathSplit.length - 1]

      puts "Passed all validation checks, part: #{partName} is ready for upload!"
      return true
    end

    desc "push <PART_PATH>", "Attempt to upload a new Rich CSS part to our servers"
    def push(part_dir_name=nil)
      part_path = "#{Dir.pwd}" + "/" + "#{part_dir_name}" || Dir.pwd
      if check(part_dir_name)
        Richcss::Manager.upload(part_path)
      end
    end
  end

  class Cli < Thor
    desc "init [css/scss]", "Initialize current directory to follow the Rich CSS framework, either css or scss files"
    # elements
    # |--- ...
    # box
    # |--- ...
    # parts
    # |--- ...
    def init(extension="css")
      if (extension.eql?("css") || extension.eql?("scss"))
        Richcss::Generators::Template.start([extension])
      else
        puts "Only support css or scss extension, default is css"
      end
    end

    desc "install <PART> [VERSION]", "Install the part requested into the Parts directory"
    def install(part_name, part_version='')
        installed_parts = Richcss::Part.get_or_create_partfile()
        if part_version.eql?('')
          RestClient.get("http://www.cssparts.com/api/part/#{part_name}") { |response, request, result, &block|
            if response.code == 200
              body = JSON.parse(response.to_str)
              part_version = body["version"]
            elsif response.code == 400
              puts "Part: #{part_name} cannot be found."
              return
            else
              puts "Error #{response.code} retrieving Part: #{part_name}"
              return
            end
          }
        else
          RestClient.get("http://www.cssparts.com/api/part/#{part_name}", {:params => {'version' => part_version}}) { |response, request, result, &block|
            if response.code == 400
              puts "Part: #{part_name} #{part_version} does not exist."
              return
            elsif response.code != 200
              puts "Error #{response.code} retrieving Part: #{part_name} #{part_version}"
              return
            end
          }
        end

        if installed_parts.key?(part_name) and installed_parts[part_name].eql?(part_version)
            puts "Part #{part_name} v#{part_version} is already installed!"
            return
        end

        partfileList = ''
        dep_list = Richcss::Part.resolve_dependencies(part_name, part_version, installed_parts)
        dep_list.each do |dep|
          Richcss::Part.fetch(dep.name, dep.version)
          partfileList << dep.name << " " << dep.version.to_s << "\n"
        end

        File.open('parts/Partfile', 'wb') do |f|
          f.write(partfileList)
        end
    end

    desc "part", "Commands for creating and uploading your own Rich CSS parts"
      subcommand "part", Part
  end
end
