module Ykutils
  module DebugUtils
    class DebugMes
      @debug = false
      @warn = false
      @buf = []

      def self.init(debug: false)
        @debug = debug
        @buf = []
      end

      class << self
        attr_accessor :debug
      end

      class << self
        attr_accessor :warn
      end

      def self.puts_x(mes)
        @buf << mes
      end

      def self.get
        @buf
      end

      def self.clear
        @buf.clear
      end
    end

    def clear_d
      Ykutils::DebugUtils::DebugMes..clear
    end

    def puts_d(mes)
      Ykutils::DebugUtils::DebugMes..puts_x(mes)
      #    puts mes
    end

    def d
      self.class.get
    end

    def puts_current_method
      d_puts caller(1)[0].split[-1]
    end

    def error_exit(num)
      puts "error(#{num})"
      pp caller(0)
      exit(n)
    end

    def debug_utils_init
      debug(false)
      set_warn(0)

      Ykutils::DebugUtils::DebugMes.init(false)
    end

    # def debug(val)
    #   # self.class.set_debug(val)
    #   Ykutils::DebugUtils::DebugMes.debug(val)
    # end

    # def debug
    #   Ykutils::DebugUtils::DebugMes.get_debug
    # end

    # def warn(val)
    #   Ykutils::DebugUtils::DebugMes.set_warn(val)
    # end

    # def warn
    #  Ykutils::DebugUtils::DebugMes..get_warn
    # end

    def d_exit(num)
      exit(num) if get_debug
    end

    def d_puts(str)
      puts(str) if get_debug
    end

    def w1_puts(str)
      set_warn(0) unless get_warn
      puts(str) if get_debug || (get_warn >= 1)
    end

    def w2_puts(str)
      set_warn(0) unless get_warn
      puts(str) if get_debug || (get_warn >= 2)
    end

    def d_caller(_num)
      pp caller(0) if get_debug
    end

    def puts_no_empty(mes)
      puts mes if mes != ""
    end

    def d_puts_no_empty(mes)
      puts mes if (mes != "") && get_debug
    end

    def d_p(mes)
      p mes if get_debug
    end

    def d_pp(mes)
      if debug
        pp "debug=#{debug}"
        pp caller(0)
        exit
      end
      pp mes if get_debug
    end
  end
end
