require 'thor'
require 'richcss'

module RichcssCLI
  class Part < Thor
  desc "init <PART_NAME>", "Generate a skeleton directory for your new Rich CSS part"
    # part_name
    # |--- lib
    # |    |--- elements
    # |    |    |--- ...
    # |    |--- box
    # |    |    |--- ...
    # |--- part_name.spec
    # |--- README.md
    def init(part)
      Richcss::Generators::PartTemplate.start([part])
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
    desc "init", "Initialize current directory to follow the Rich CSS framework"
    # elements
    # |--- ...
    # box
    # |--- ...
    # parts
    # |--- ...
    def init()
      Richcss::Generators::Template.start([part])
    end

    desc "install <PART> [VERSION]", "Install the Parts requested into the Parts directory of Rich CSS framework"
    def install(part_name, part_version='')
        installed_parts = Richcss::Part.get_or_create_partfile()
        if part_version.eql?('')
          resp = RestClient.get "http://localhost:3000/api/part/#{part_name}"
          if resp.code == 200
            body = JSON.parse(resp.to_str)
            part_version = body["version"]
          end
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
