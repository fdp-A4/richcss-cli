module Richcss::VersionKit
  #
  #
  class RequirementList
    # @return [Array<Requirement>]
    #
    attr_reader :requirements

    #-------------------------------------------------------------------------#

    # @param [Array<Requirement>] @see #requirements.
    #
    def initialize(requirements = [])
      @requirements = Array(requirements).map do |requirement|
        normalize_requirement(requirement)
      end
    end

    # @return [void]
    #
    def add_requirement(requirement)
      requirement = normalize_requirement(requirement)
      requirements << requirement
      requirements.uniq!
    end

    # @return [Bool]
    #
    def satisfied_by?(candidate_version)
      requirements.all? do |requirement|
        requirement.satisfied_by?(candidate_version)
      end
    end

    public

    # @!group Object methods
    #-------------------------------------------------------------------------#

    # @return [String] the string representation of this class. The string is
    #         equivalent, but not strictly equal, to the one used on
    #         initialization.
    #
    def to_s
      requirements.map(&:to_s).join(', ')
    end

    # @return [Fixnum] The hash of the instance.
    #
    def hash
      to_s.hash
    end

    def ==(other)
      requirements == other.requirements
    end

    private

    # @!group Private Helpers
    #-------------------------------------------------------------------------#

    def normalize_requirement(requirement)
      case requirement
      when Requirement
        requirement
      when String, Version
        Requirement.new(requirement)
      else
        raise ArgumentError, 'Unable to normalize requirement ' \
          "`#{requirement.inspect}`"
      end
    end

    #-------------------------------------------------------------------------#
  end
end
