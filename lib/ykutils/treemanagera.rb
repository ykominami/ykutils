require "ykutils/treemanager"

module Ykutils
  class TreeManager
    def add_tag(node_name, tag_name)
      @tag ||= {}

      if @tag[node_name]
        @tag[node_name] << tag_name
      else
        @tag[node_name] = [tag_name]
      end
    end

    def tag(node_name)
      ret = nil
      ret = @tag[node_name] if @tag
      ret
    end
  end
end
