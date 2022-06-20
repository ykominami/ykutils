require "ykutils/debugutils"
require "ykutils/stext"
require "ykutils/xlines"

module Ykutils
  class StructuredTextForX < StructuredText
    include DebugUtils

    def initialize(debug = false)
      super()

      debug_utils_init
      set_debug(debug)
      ends

      def analyze(line_ary, _fname = nil)
        lines = XLines.new(line_ary)
        #    lines.output_f( fname )

        analyze_sub(lines)
      end

      def analyze_sub(lines)
        puts_current_method

        while line = lines.get_line
          #      p line
        end
      end
    end
  end
end
