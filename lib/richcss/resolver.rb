require 'molinillo'
require 'richcss/vendor/version_kit/lib/version_kit'

module Richcss
  class Resolver

    def self.start(part_name, version, installed = {})
      installed_deps = []
      installed.each do | p, v |
        installed_deps.push(VersionKit::Dependency.new(p, v))
      end
      @resolver = Molinillo::Resolver.new(RichSpecificationProvider.new(part_name, version), RichUI.new)
      @base_dg = Molinillo::DependencyGraph.new
      installed_deps.each { |dep| @base_dg.add_vertex dep.name, dep }
      requirements = [VersionKit::Dependency.new(part_name, version)]
      dg = @resolver.resolve(requirements, @base_dg)
      puts "Succesfully resolved dependencies\n"
      new_deps = dg.map(&:payload).flatten
      new_deps.each { |dep| installed[dep.name] = dep.version }
      return installed
    rescue Molinillo::VersionConflict => e
      puts e
      return nil
    rescue Molinillo::CircularDependencyError => e
      names = e.dependencies.sort_by(&:name).map {|d| "gem '#{d.name}'" }
      puts "Your RichCSS part requires parts that depend" \
        " on each other, creating an circular loop. Please remove" \
        " #{names.count > 1 ? "either " : ""}#{names.join(" or ")}" \
        " and try again."
      return nil
    end
  end
end
