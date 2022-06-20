require "tsort"

module Ykytils
  class TreeManager
    include TSort

    def initialize
      @table = {}
    end

    def add(parent_name, name)
      if parent_name
        parent = @table[parent_name]
        if parent
          @table[parent_name] << name
        else
          @table[parent_name] = [name]
        end
      else
        @table[name] = []
      end
    end

    def tsort_each_child(node, &block)
      ary = @table[node]
      ary.each(&block) if ary
    end

    def tsort_each_node(&block)
      @table.keys.each(&block)
    end
  end
end
