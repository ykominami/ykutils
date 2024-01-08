module Ykutils
  require "find"
  class Nginxconfigfiles
    def get_file_list(start_dir, reg)
      @file_list = []

      Find.find(start_dir) do |x|
        next unless x =~ reg

        # puts x
        @file_list << x
        Find.prune
      end
      @file_list
    end

    def output(file_list)
      file_list.map do |fname|
        parent_dir_pn = Pathname.new(fname).cleanpath.parent
        vdomain = parent_dir_pn.basename
        output_fname = "#{vdomain}.conf"
        cli = Nginxconfig.new(fname)
        scope = nil
        File.open(output_fname, "w") do |f|
          x = cli.extract(scope)
          f.write(x)
        end
      end
    end
  end
end
