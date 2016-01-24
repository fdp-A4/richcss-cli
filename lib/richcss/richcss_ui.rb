require 'molinillo'

module Richcss
  class RichUI
    include Molinillo::UI
    # Conveys debug information to the user.
    #
    # @param [Integer] depth the current depth of the resolution process.
    # @return [void]
    def debug(depth = 0)
      if debug?
        debug_info = yield
        debug_info = debug_info.inspect unless debug_info.is_a?(String)
        STDERR.puts debug_info.split("\n").map {|s| "  " * depth + s }
      end
    end

    def debug?
      ENV["DEBUG_RESOLVER"] || ENV["DEBUG_RESOLVER_TREE"]
    end

    def before_resolution
      Bundler.ui.info "Resolving dependencies...", false
    end

    def after_resolution
      Bundler.ui.info ""
    end

    def indicate_progress
      Bundler.ui.info ".", false
    end
  end
end
