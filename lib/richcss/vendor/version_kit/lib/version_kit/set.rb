module Richcss::VersionKit
  #
  #
  class Set
    # @return [String] the name of the Pod.
    #
    attr_reader :name

    # @return [Array<Source>] the sources that contain the specifications for
    #         the available versions of a Pod.
    #
    attr_reader :versions

    # @param  [String] name
    #         the name of the Pod.
    #
    # @param  [Array<Source>,Source] sources
    #         the sources that contain a Pod.
    #
    def initialize(name, versions)
      @name = name
      @versions = Array(versions)
    end
  end
end
