require "ykutils/filepermision"
require "pathname"

module Ykytils
  class DirEntryItem
    attr_accessor :name, :user, :group, :size, :month, :day, :time, :year, :path, :type, :parent_dir, :valid

    def initialize; end

    def parse(str, parent_dir, valid = true)
      ary = str.split(/\s+/)
      perm = ary[0]
      @type = if perm[0].chr == "d"
          :DIRECTORY
        else
          :FILE
        end
      @perm = FilePermision.new(ary[0][1..9])
      @value = ary[1]
      @user = ary[2]
      @group = ary[3]
      @size = ary[4]
      @month = ary[5]
      @day = ary[6]
      str = ary[7]
      if str =~ /:/
        @year = Time.now.year
        @time = str
      else
        @year = str
        @time = "00:00:00"
      end

      @time = ary[7]
      @name = ary[8]
      @path = File.join(parent_dir, @name)
      @parent_dir = parent_dir
      @valid = valid
    end

    def to_hash
      { "type" => @type, "perm" => @perm.to_hash, "value" => @value, "user" => @user, "group" => @group,
        "size" => @size, "month" => @month, "day" => @day, "year" => @year,
        "time" => @time, "name" => @name, "path" => @path, "parent_dir" => @parent_dir, "valid" => @valid }
    end

    def to_csv
      "#{@type},#{@perm},#{@value},#{@user},#{@group},#{@size},#{@year},#{@month},#{@day},#{@time},#{@name},#{@parent_dir},#{@valid}"
    end

    def directory?
      @type === :DIRECTORY
    end

    def file?
      @type === :FILE
    end

    def owner_perm
      @perm.owner
    end

    def group_perm
      @perm.group
    end

    def otherr_perm
      @perm.other
    end
  end
end
