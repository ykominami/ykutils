module Ykutils
  class FilePermision
    attr_reader :owner, :group, :other

    class PermisionEntry
      def initialize(str)
        @read = str[0].chr
        @write = str[1].chr
        @exec = str[2].chr
      end

      def to_s
        @read + @write + @exec
      end

      def to_hash
        { "read" => @read, "write" => @write, "exec" => @exec }
      end
    end

    def initialize(str)
      @owner = PermisionEntry.new(str[0..2])
      @group = PermisionEntry.new(str[3..5])
      @other = PermisionEntry.new(str[6..8])
    end

    def to_s
      @owner.to_s + @group.to_s + @other.to_s
    end

    def to_hash
      { "owner" => @owner.to_hash, "group" => @group.to_hash, "other" => @other.to_hash }
    end
  end
end
