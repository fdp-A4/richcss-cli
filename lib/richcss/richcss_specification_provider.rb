require 'version_kit'
require 'molinillo'

module Richcss
  class RichSpecificationProvider
    attr_accessor :specs
    attr_accessor :part_name
    attr_accessor :version

    include Molinillo::SpecificationProvider

    def initialize(name, version)
      self.part_name = name
      self.version = version
      response = RestClient.get "http://localhost:3000/api/part/#{name}/dependency", {:params => {'version' => version}}
      if response.code == 200
        self.specs = JSON.load(response.body).reduce(Hash.new([])) do |specs_by_name, (dep_name, dep_versions)|
          specs_by_name.tap do |specs|
            specs[dep_name] = dep_versions.map { |s| Richcss::TestSpecification.new s }.sort_by(&:version)
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
