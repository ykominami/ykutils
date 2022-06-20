require "pp"

module Ykutils
  module DebugUtils
    class DebugMes
      def self.init(debug = false)
        @@debug = debug
        @@buf = []
      end

      def self.set_debug(debug)
        @@debug = debug
      end

      def self.puts_x(mes)
        @@buf ||= []
        @@buf << mes
        #      puts "#{@@buf.size} |#{mes}"
      end

      def self.get
        @@buf
        #      DebugMes.clear
      end

      def self.clear
        @@buf ||= []
        @@buf.clear
      end
    end

    def clear_d
      DebugMes.clear
    end

    def puts_d(mes)
      DebugMes.puts_x(mes)
      #    puts mes
    end

    def get_d
      DebugMes.get
    end

    def puts_current_method
      d_puts (caller(1)[0].split)[-1]
    end

    def error_exit(n)
      puts "error(#{n})"
      pp caller(0)
      exit(n)
    end

    def debug_utils_init
      set_debug(false)
      set_warn(0)

      DebugMes.init(false)
    end

    def set_debug(val)
      @debugutils = val
      DebugMes.set_debug(val)
    end

    def get_debug
      @debugutils
    end

    def set_warn(val)
      @warn = val
    end

    def debug
      @debugutils
    end

    def d_exit(num)
      exit(num) if @debugutils
    end

    def d_puts(str)
      puts(str) if @debugutils
    end

    def w1_puts(str)
      set_warn(0) unless @warn
      puts(str) if @debugutils or @warn >= 1
    end

    def w2_puts(str)
      set_warn(0) unless @warn
      puts(str) if @debugutils or @warn >= 2
    end

    def d_caller(_num)
      pp caller(0) if @debugutils
    end

    def puts_no_empty(mes)
      puts mes if mes != ""
    end

    def d_puts_no_empty(mes)
      puts mes if mes != "" and @debugutils
    end

    def d_p(it)
      p it if @debugutils
    end

    def d_pp(it)
      if @debugutils
        pp "@debugutils=#{@debugutils}"
        pp caller(0)
        exit
      end
      pp it if @debugutils
    end
  end
end
