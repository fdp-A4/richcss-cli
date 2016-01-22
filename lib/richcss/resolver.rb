require 'molinillo'
require 'version_kit'
require 'json'
require 'pathname'

module Richcss
  class Resolver

    # For testing
    #require File.expand_path('../dependencytestjson', __FILE__)

    #def initialize()
      #@index = index
      #@source_requirements = source_requirements
      #@base = base
      #@resolver = Molinillo::Resolver.new(RichSpecificationProvider.new, Molinillo::UI.new)
      #@base_dg = Molinillo::DependencyGraph.new
      #@base.each { |ls| @base_dg.add_vertex(ls.name, Dependency.new(ls.name, ls.version), true) }
    #end

    # def self.resolveTest()
    #   puts "Begin dependency resolution tests\n"

    #   Dir.glob('lib/richcss/dependencytestjson/case/*.json').map do |fixture_path| # TODO change awesome -> *
    #     puts "Test #{fixture_path}\n"
    #     File.open(fixture_path) do |fixture|
    #       JSON.load(fixture).tap do |test_case|
    #         requirements = test_case['requested'].map do |(name, reqs)| # TODO figure this out
    #           VersionKit::Dependency.new name, reqs.split(',').map(&:chomp)
    #         end
    #         fixture_path_index = 'lib/richcss/dependencytestjson/index/' + (test_case['index'] || 'awesome') + '.json'
    #         dg = start(requirements, fixture_path_index)
    #       end
    #     end
    #   end
    # end

    def self.start(part_name, version)
      requirements = Hash[part_name, version]
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
