require 'version_kit'
require 'molinillo'

module Richcss
  class RichSpecificationProvider
    attr_accessor :specs
    include Molinillo::SpecificationProvider

    def initialize(fixture_file)
      File.open(fixture_file, 'r') do |fixture|
        self.specs = JSON.load(fixture).reduce(Hash.new([])) do |specs_by_name, (name, versions)|
          specs_by_name.tap do |specs|
            specs[name] = versions.map { |s| Richcss::TestSpecification.new s }.sort_by(&:version)
          end
        end
      end
    end

    def requirement_satisfied_by?(requirement, _activated, spec)
      requirement.satisfied_by?(spec.version)
    end

    def search_for(dependency)
      @search_for ||= {}
      @search_for[dependency] ||= begin
        pre_release = dependency_pre_release?(dependency)
        specs[dependency.name].select do |spec|
          (pre_release ? true : !spec.version.pre_release?) &&
            dependency.satisfied_by?(spec.version)
        end
      end
    end

    def name_for(dependency)
      dependency.name
    end

    def name_for_explicit_dependency_source
      'Partfile'
    end

    def name_for_locking_dependency_source
      'Partfile.lock'
    end

    def dependencies_for(dependency)
      dependency.dependencies
    end

    def sort_dependencies(dependencies, activated, conflicts)
      dependencies.sort_by do |d|
        [
          activated.vertex_named(d.name).payload ? 0 : 1,
          dependency_pre_release?(d) ? 0 : 1,
          conflicts[d.name] ? 0 : 1,
          activated.vertex_named(d.name).payload ? 0 : search_for(d).count,
        ]
      end
    end

    private

    def dependency_pre_release?(dependency)
      dependency.requirement_list.requirements.any? do |r|
        VersionKit::Version.new(r.reference_version).pre_release?
      end
    end
  end
end
