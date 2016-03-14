module Richcss::VersionKit
  class Version
    # Identifies the possible next versions from a given one.
    #
    module Helper
      # Bumps the component at the given index
      # @param  [Version, #to_s] version
      # @param  [#to_i] component
      # @return [Version]
      #
      def self.bump(version, index)
        index = index.to_i
        unless (0..2).include?(index)
          raise ArgumentError, "Unsupported index `#{index}`"
        end

        version = coherce_version(version)
        number_components = version.number_component[0..index]
        number_components[index] = number_components[index].succ
        Version.new([number_components])
      end

      # @param  [Version, #to_s] version
      # @return [Version]
      #
      def self.next_major(version)
        bump(version, 0)
      end

      # @param  [Version, #to_s] version
      # @return [Version]
      #
      def self.next_minor(version)
        bump(version, 1)
      end

      # @param  [Version, #to_s] version
      # @return [Version]
      #
      def self.next_patch(version)
        bump(version, 2)
      end

      # @param  [Version, #to_s] version
      # @return [Version]
      # @return [Nil]
      #
      def self.next_pre_release(version)
        version = coherce_version(version)
        return nil unless version.pre_release_component
        pre_release_component = []
        version.pre_release_component.each do |element|
          element = element.succ if element.is_a?(Fixnum)
          pre_release_component << element
        end
        if version.pre_release_component != pre_release_component
          Version.new([version.number_component, pre_release_component])
        end
      end

      # @param  [Version, #to_s] version
      # @return [Array<Version>] All the possible versions the given one
      #         might evolve in.
      #
      def self.next_versions(version)
        version = coherce_version(version)
        [
          next_major(version),
          next_minor(version),
          next_patch(version),
          next_pre_release(version)
        ].compact
      end

      # @param  [Version, #to_s] version
      # @param  [Version, #to_s] candidate
      # @return [Bool]
      #
      def self.valid_next_version?(version, candidate)
        version = coherce_version(version)
        candidate = coherce_version(candidate)
        next_versions(version).include?(candidate)
      end

      # @return [Version] The version stripped of any pre-release or build
      #         metadata.
      #
      def self.release_version(version)
        version = coherce_version(version)
        Version.new([version.number_component])
      end

      # @return [String] The optimistic requirement (`~>`) which, according to
      #         SemVer, preserves backwards compatibility.
      #
      def self.optimistic_requirement(version)
        version = coherce_version(version)
        if version.major_version == 0
          "~> #{version.number_component[0..2].join('.')}"
        else
          "~> #{version.number_component[0..1].join('.')}"
        end
      end

      # @param  [Version, #to_s] version
      # @return [Version]
      #
      def self.coherce_version(version)
        if version.is_a?(Version)
          version
        else
          Version.new(version)
        end
      end
    end
  end
end
