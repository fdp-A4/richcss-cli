module Richcss::VersionKit
  class Version
    # Provides support for working with version components and comparing them.
    #
    # Assumes identifiers converted to the appropriate class as the ones
    # returned by the `::split_identifiers` method.
    #
    module ComponentsHelper
      # Splits a string representing a component in a list of the single
      # identifiers (separated by a dot). Identifiers composed only by digits
      # are converted to an integer in the process.
      #
      # @param  [Array<String>] components
      #         The list of the components.
      #
      # @return [Array<String,Fixnum>] The list of the elements of the
      #         component.
      #
      def self.split_components(version)
        component_strings = version.scan(/[^-+]+/)
        (0...3).map do |index|
          indentifiers_string = component_strings[index]
          if indentifiers_string
            ComponentsHelper.split_identifiers(indentifiers_string)
          else
            []
          end
        end
      end

      # Splits a string representing a component in a list of the single
      # identifiers (separated by a dot). Identifiers composed only by digits
      # are converted to an integer in the process.
      #
      # @param  [String] component
      #         The string of the component to split in identifiers.
      #
      # @return [Array<String,Fixnum>] The list of the identifiers of the
      #         component.
      #
      def self.split_identifiers(component)
        component.split('.').map do |identifier|
          if identifier =~ /\A[0-9]+\Z/
            identifier.to_i
          else
            identifier
          end
        end
      end

      # Compares the number component of one version with the one of another
      # version.
      #
      # @param  [Array<Fixnum>] first
      #         The component of the first version.
      #
      # @param  [Array<Fixnum>] second
      #         The component of the second version.
      #
      # @return [Fixnum] See #<=>
      #
      def self.compare_number_component(first, second)
        count = [first.count, second.count].max
        count.times do |index|
          result = first[index].to_i <=> second[index].to_i
          return result unless result.zero?
        end

        nil
      end

      # Compares the pre-release component of one version with the one of
      # another version.
      #
      # @param  [Array<Fixnum>] first
      #         The component of the first version.
      #
      # @param  [Array<Fixnum>] second
      #         The component of the second version.
      #
      # @return [Fixnum] See #<=>
      #
      def self.compare_pre_release_component(first, second)
        result = (first.empty? ? 1 : 0) <=> (second.empty? ? 1 : 0)
        return result unless result.zero?

        count = [first.count, second.count].max
        count.times do |index|
          result = compare_pre_release_identifiers(first[index], second[index])
          return result unless result.zero?
        end

        nil
      end

      # Compares two pre-release identifiers.
      #
      # @param  [String,Fixnum] fist
      #         The first identifier to compare.
      #
      # @param  [String,Fixnum] second
      #         The second identifier to compare.
      #
      # @return [Fixnum] See #<=>
      #
      def self.compare_pre_release_identifiers(first, second)
        result = compare(first, second)
        result ||= compare(first.is_a?(String), second.is_a?(String))
        return result if result

        if first.is_a?(Fixnum)
          first.to_i <=> second.to_i
        elsif first.is_a?(String)
          first.to_s <=> second.to_s
        end
      end

      # Compares two boolean values returning a comparison result if only one
      # condition is truthy.
      #
      # @param  [Object] fist
      #         The first object to compare.
      #
      # @param  [Object] second
      #         The second object to compare.
      #
      # @return [Fixnum] See #<=>
      # @return [Nil] If the comparison didn't produce any result.
      #
      def self.compare(first, second)
        if first && !second
          +1
        elsif second && !first
          -1
        else
          nil
        end
      end

      # Checks whether the given components are valid.
      #
      # @param  [Array<Array<String, Fixnum>>] components
      #         The components to check.
      #
      # @return [Bool] If the given components are valid.
      #
      # rubocop:disable CyclomaticComplexity
      #
      def self.validate_components?(components)
        components.is_a?(Array) &&
          components.map(&:class).uniq == [Array] &&
          components.count == 3 &&
          components.first.count == 3 &&
          (components[0].map(&:class) - [Fixnum]).empty? &&
          (components[1].map(&:class) - [String, Fixnum]).empty? &&
          (components[2].map(&:class) - [String, Fixnum]).empty?
      end
      #
      # rubocop:enable CyclomaticComplexity
    end
  end
end
