require "ykutils/treemanager"

module Ykutils
  class TreeManager
    def addTag(node_name, tag_name)
      @tag ||= {}

      if @tag[node_name]
        @tag[node_name] << tag_name
      else
        @tag[node_name] = [tag_name]
      end
    end

    def getTag(node_name)
      ret = nil
      ret = @tag[node_name] if @tag
      ret
    end
  end
end
