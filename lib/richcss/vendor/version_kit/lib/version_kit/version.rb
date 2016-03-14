require 'richcss/vendor/version_kit/lib/version_kit/version/helper'
require 'richcss/vendor/version_kit/lib/version_kit/version/components_helper'

module Richcss::VersionKit
  # Model class which provides support for versions according to the [Semantic
  # Versioning Specification](http://semver.org).
  #
  # Currently based on Semantic Versioning 2.0.0.
  #
  # Example version: 1.2.3-rc.1+2014.01.01
  #
  # Glossary:
  #
  # - version: a string representing a specific release of a software.
  # - component: a version can have 3 components the number (1.2.3), the
  #   pre-release metadata (rc.1), and the Build component (2014.01.01).
  # - identifier: each component in turn is composed by multiple identifier
  #   separated by a dot (like 1, 2, or 01).
  # - bumping: the act of increasing by a single unit one identifier of the
  #   version.
  #
  class Version
    # @return [RegEx] The regular expression to use to validate a string
    #         representation of a version.
    #
    # The components have the following characteristics:
    #
    # - Number component: Three dot-separated numeric elements.
    # - Pre-release component: Hyphen, followed by any combination of digits,
    #   letters, or hyphens separated by periods.
    # - Build component: Plus sign, followed by any combination of digits,
    #   letters, or hyphens separated by periods.
    #
    VERSION_PATTERN = /\A
      [0-9]+\.[0-9]+\.[0-9]+           (?# Number component)
      ([-][0-9a-z-]+(\.[0-9a-z-]+)*)?  (?# Pre-release component)
      ([+][0-9a-z-]+(\.[0-9a-z-]+)*)?  (?# Build component)
    \Z/xi

    include Comparable

    # @return [Array<Array<Fixnum,String>>] The list of the components of the
    # version.
    #
    attr_reader :components

    # The Semantic Versioning Specification mandates a number component
    # composed by 3 identifiers. Therefore strictly speaking `1` and `1.0`
    # are not versions according the specification. This class accepts those
    # values normalizing them to `1.0.0`. To ensure strict adherence to the
    # standard clients can use the `Version::valid?` method to check any
    # string.
    #
    # @param  [#to_s, Array<Array<String, Fixnum>>] version
    #         A representation of a version convertible to a string or the
    #         components of a version.
    #
    # @raise  If initialized with a string which cannot be converted to a
    #         version.
    #
    # rubocop:disable MethodLength
    #
    def initialize(version_or_components)
      if version_or_components.is_a?(Array)
        components = self.class.normalize_components(version_or_components)
        unless ComponentsHelper.validate_components?(components)
          raise ArgumentError, "Malformed version components `#{components}`"
        end
        @components = components

      else
        version = self.class.normalize(version_or_components)
        unless self.class.valid?(version)
          raise ArgumentError, "Malformed version `#{version}`"
        end
        @components = ComponentsHelper.split_components(version)
      end
    end
    #
    # rubocop:enable MethodLength

    # @!group Class methods
    #-------------------------------------------------------------------------#

    # Normalizes the given string representation of a version by defaulting
    # the minor and the patch version to 0 if possible.
    #
    # @param  [#to_s] version
    #         The string representation to normalize.
    #
    # @return [String] The normalized or the original version.
    #
    def self.normalize(version)
      version = version.to_s.strip
      version << '.0' if version  =~ /\A[0-9]+\Z/
      version << '.0' if version  =~ /\A[0-9]+\.[0-9]+\Z/
      version
    end

    # Normalizes the given version components by defaulting the minor and the
    # patch version to 0 if possible.
    #
    # @param  [Array<Array<String, Fixnum>>] components
    #         The components to normalize.
    #
    # @return [Array] The normalized or the original components.
    #
    def self.normalize_components(components)
      if components.is_a?(Array) && components[0].is_a?(Array)
        count = components.count
        components = components.fill([], count, 3 - count) if count < 3

        number_count = components[0].count
        if number_count < 3
          components[0] = components[0].fill(0, number_count, 3 - number_count)
        end
      end

      components
    end

    # @return [Bool] Whether a string representation of a version is can be
    #         accepted by this class. This comparison is much more lenient than
    #         the requirements described in the SemVer specification to support
    #         the diversity of versioning practices found in practice.
    #
    def self.valid?(version)
      !(version.to_s =~ VERSION_PATTERN).nil?
    end

    # @!group Semantic Versioning
    #-------------------------------------------------------------------------#

    # @return [Array<Fixnum>] The list of the identifiers of the number
    #         component.
    #
    def number_component
      @components[0]
    end

    # @return [Array<String, Fixnum>] The list of the identifiers of the
    #         pre-release component.
    #
    def pre_release_component
      @components[1]
    end

    # @return [Array<String, Fixnum>] The list of the identifiers of the build
    #         component.
    #
    def build_component
      @components[2]
    end

    # @return [Fixnum] The major version.
    #
    def major_version
      number_component[0]
    end

    # @return [Fixnum] The minor version.
    #
    def minor
      number_component[1]
    end

    # @return [Fixnum] The patch version.
    #
    def patch
      number_component[2]
    end

    # @return [Boolean] Indicates whether or not the version is a pre-release
    #         version.
    #
    def pre_release?
      !pre_release_component.empty?
    end

    # @!group Object methods
    #-------------------------------------------------------------------------#

    # @return [String] The string representation of the version.
    #
    def to_s
      result = number_component.join('.')

      if pre_release_component.count > 0
        result << '-' << pre_release_component.join('.')
      end

      if build_component.count > 0
        result << '+' << build_component.join('.')
      end

      result
    end

    # @return [String] a string representation suitable for debugging.
    #
    def inspect
      "<#{self.class} #{self}>"
    end

    # @return [Bool]
    #
    def ==(other)
      to_s == other.to_s
    end

    # Returns whether a hash should consider equal two versions for being used
    # as a key. To be considered equal versions should be specified with the
    # same precision (i.e. `'1.0' != '1.0.0'`)
    #
    # @param  [Object] The object to compare.
    #
    # @return [Bool] whether a hash should consider other as an equal key to
    #         the instance.
    #
    def eql?(other)
      self.class == other.class && to_s == other.to_s
    end

    # @return [Fixnum] The hash value for this instance.
    #
    def hash
      [to_s].hash
    end

    # Compares the instance to another version to determine how it sorts.
    #
    # @param  [Object] The object to compare.
    #
    # @return [Fixnum] -1 means self is smaller than other. 0 means self is
    #         equal to other. 1 means self is bigger than other.
    # @return [Nil] If the two objects could not be compared.
    #
    # @note   From semver.org:
    #
    #         - Major, minor, and patch versions are always compared
    #           numerically.
    #         - When major, minor, and patch are equal, a pre-release version
    #           has lower precedence than a normal version.
    #         - Precedence for two pre-release versions with the same major,
    #           minor, and patch version MUST be determined by comparing each
    #           dot separated identifier from left to right until a difference
    #           is found as follows:
    #           - identifiers consisting of only digits are compared
    #             numerically and identifiers with letters or hyphens are
    #             compared lexically in ASCII sort order.
    #           - Numeric identifiers always have lower precedence than
    #             non-numeric identifiers.
    #           - A larger set of pre-release fields has a higher precedence
    #             than a smaller set, if all of the preceding identifiers are
    #             equal.
    #         - Build metadata SHOULD be ignored when determining version
    #           precedence.
    #
    def <=>(other)
      return nil unless other.class == self.class
      result = nil

      result ||= ComponentsHelper.compare_number_component(
        number_component, other.number_component
      )

      result ||= ComponentsHelper.compare_pre_release_component(
        pre_release_component, other.pre_release_component
      )

      result || 0
    end
  end
end
