require "pathname"

module Ykutils
  module PathOp
    def get_buddy_path(fname, append_name = "", extname = "")
      one_path = Pathname.new(fname).expand_path
      dir_path = one_path.dirname
      base_path = one_path.basename(".*")
      append_name = "-2" unless append_name.empty? || extname.empty?
      extname ||= one_path.extname

      [one_path, dir_path.join(base_path.to_s + append_name + extname)]
    end

    def determine_fname_for_update(fname, ext = ".bak")
      get_buddy_path(fname, "", ext)
    end

    def determine_fname_for_update2(fname)
      begin
        ctime = File.ctime(fname)
      rescue YkutilsError => e
        puts e
      end
      ctime ||= Time.now
      ary = ctime.to_s.split
      extname = File.extname(fname)
      append = ["", ary[0], ary[1].gsub(":", "-")].join("-")
      get_buddy_path(fname, append, extname)
    end

    def file_ensure(fname)
      File.open(fname, "w").close unless File.exist?(fname)
    end
  end
end
