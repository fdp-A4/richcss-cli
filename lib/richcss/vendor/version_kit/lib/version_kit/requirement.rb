module Richcss::VersionKit
  # Describes a constraint on the acceptable elements of a list of versions.
  # The only relevant method for this class is the `#satisfied_by?` method.
  #
  # The optimistic requirement is deemed optimistic because the user if
  # optimistic about the correct versioning of the software the requirement
  # refers to.
  #
  class Requirement
    # @return [String] The operator of the constraint.
    #
    attr_reader :operator

    # @return [String] The reference version of the operator.
    #
    attr_reader :reference_version

    # @return [Hash {String=>Lambda}] The operators supported by this class
    #         associated to the lambda used to evaluate them.
    #
    OPERATORS = ['=', '!=', '>', '<', '>=', '<=', '~>']

    # @param  [String] string The string representation of the requirement.
    #
    def initialize(string)
      operator, reference_version = parse_string(string)
      check_parsing(string, operator, reference_version)

      @operator = operator
      @reference_version = reference_version
      @reference = Version.new(reference_version)
    end

    # @param  [String] candidate_version
    #
    # @return [Bool] Whether a given version is accepted by the given
    #         requirement.
    #
    # rubocop:disable MethodLength, CyclomaticComplexity
    #
    def satisfied_by?(candidate_version)
      candidate = Version.new(candidate_version)
      reference = @reference

      case operator
      when '='  then candidate == reference
      when '!=' then candidate != reference
      when '>'  then candidate >  reference
      when '<'  then candidate <  reference
      when '>=' then candidate >= reference
      when '<=' then candidate <= reference
      when '~>'
        candidate >= reference && candidate < bumped_reference_version
      end
    end
    #
    # rubocop:enable MethodLength, CyclomaticComplexity

    public

    # @!group Object methods
    #-------------------------------------------------------------------------#

    # @return [String] the string representation of this class. The string is
    #         equivalent, but not strictly equal, to the one used on
    #         initialization.
    #
    def to_s
      "#{operator} #{reference_version}"
    end

    # @return [Fixnum] Useful for sorting a list of requirements.
    #
    def <=>(other)
      to_s <=> other.to_s
    end

    # @return [Fixnum] The hash of the instance.
    #
    def hash
      to_s.hash
    end

    def ==(other)
      operator == other.operator &&
        reference_version == other.reference_version
    end

    private

    # @!group Private Helpers
    #-------------------------------------------------------------------------#

    # @param  [String] string
    #
    # @return [Array<String, String>]
    #
    def parse_string(string)
      splitted = string.to_s.strip.split(' ')
      if splitted.count == 1
        operator = '='
        version = splitted[0]
      else
        operator = splitted[0]
        version = splitted[1]
      end
      @version_specificity = version.scan(/[^-+]+/).first.split('.').count
      version = Version.normalize(version) if version
      [operator, version]
    end

    # @param  [String] string
    #
    # @param  [String] operator
    #
    # @param  [String] version
    #
    # @return [void] Checks that the initialization string and the result of
    #         the parsing are acceptable.
    #
    def check_parsing(string, operator, version)
      unless OPERATORS.include?(operator)
        raise ArgumentError, "Unsupported operator `#{operator}` " \
          "requirement `#{string}`"
      end

      unless Version.valid?(version)
        raise ArgumentError, "Malformed version `#{version}` for " \
          "requirement `#{string}`"
      end
    end

    # @return [Bool] Whether a given candidate versions is acceptable according
    #         to the optimistic operator (`~>`) given the reference version.
    #
    def bumped_reference_version
      index = @version_specificity - 2
      Version::Helper.bump(reference_version, index)
    end

    #-------------------------------------------------------------------------#
  end
end
