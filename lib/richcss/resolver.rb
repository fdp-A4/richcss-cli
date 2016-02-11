require 'molinillo'
require 'version_kit'

module Richcss
  class Resolver

    def self.start(part_name, version)
      requirements = [VersionKit::Dependency.new(part_name, version)]
      @resolver = Molinillo::Resolver.new(RichSpecificationProvider.new(part_name, version), RichUI.new)
      @base_dg = Molinillo::DependencyGraph.new
      dg = @resolver.resolve(requirements, @base_dg)
      puts "Succesfully resolved dependencies:\n"
      dg.map(&:payload).flatten
    rescue Molinillo::VersionConflict => e
      puts e
    rescue Molinillo::CircularDependencyError => e
      names = e.dependencies.sort_by(&:name).map {|d| "gem '#{d.name}'" }
      puts "Your RichCSS part requires parts that depend" \
        " on each other, creating an circular loop. Please remove" \
        " #{names.count > 1 ? "either " : ""}#{names.join(" or ")}" \
        " and try again."
    end
  end
end
