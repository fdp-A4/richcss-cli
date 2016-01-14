require 'richcss'

module Richcss
  class Manager
    def self.release()
        puts "Creating a release..."
    end

    # Checks if the current directory has the RichCSS folder format
    def self.check(part_name)
        # Check for root directory directory

        # LEVEL 1
        if !Dir.exist?(part_name)
            return false
        end

        # Search for spec file and readme
        foundReadme = false;
        foundSpec = false;
        Dir.foreach(part_name) do |filename|
            next if filename == '.' or filename == '..'
            if filename == "#{part_name.downcase}.spec"
                foundSpec = true
            end
            if filename == "README.md"
                foundReadme = true
            end
        end

        if (!foundSpec || !foundReadme)
            return false
        end
        puts "DONE LEVEL 1"

        # LIB CHECK
        Dir.chdir(part_name)
        if !Dir.exist?('lib')
            return false
        end 

        puts "DONE LIB CHECK"

        # LEVEL 2 / LIB
        Dir.chdir('lib')
        groups = ['box', 'elements', 'parts']

        groups.each do |g|
            if !Dir.exist?(g)
                return false
            end
        end

        puts "DONE LEVEL 2"

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
            return false
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
            return false
        end

        puts "DONE LEVEL 3"

        # SPEC FILE CHECK

        puts "Success!!"
        return true
    end
  end
end
