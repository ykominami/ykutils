require "ykutils/debugutils"
require "ykutils/stextx"
require "ykutils/yamlop"

module Ykutils
  class YamlXOp < YamlOp
    attr_accessor :yaml

    include DebugUtils

    def initialize(_opt, _args, debug)
      debug_utils_init
      set_debug(debug)
    end

    def load(fname)
      #    d_puts "3"
      #    puts_current_method

      #    d_puts "fname=#{fname}"
      @fname = fname
      #    @pstext = StructuredTextForX.new
      #    puts "fname=#{fname}"
      #    @pstext.load_analyze( fname )
      @yaml = load_yaml_file(fname)
    end

    def yaml2stext
      yaml_str = YAML.dump(@yaml)
      yaml_ary = yaml_str.split("\n")
      @yamlstext = StructuredTextForAccount.new
      @yamlstext.analyze(yaml_ary)
    end
  end
end
