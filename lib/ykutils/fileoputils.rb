require "ykutils/stringutils"
require "ykutils/retcodex"
require "ykutils/debugutils"

module Ykutils
  module FileOpUtils
    include StringUtils
    include DebugUtils

    WRITABLE_FILE_PATH = 11
    VALID_FILE_PATH = 10
    ABNORMAL_STRING = -5
    INVALID_FILE_PATH = -10
    NOT_WRITABLE_FILE_PATH = -11

    VALID_PATH = 20
    INVALID_PATH = -20

    def valid?
      @valid
    end

    def valid_fpath(fname)
      ret = VALID_FILE_PATH
      if normal_string?(fname)
        ret = INVALID_FILE_PATH unless File.file?(fname)
      else
        ret = ABNORMAL_STRING
      end
      ret
    end

    def valid_path(path)
      ret = VALID_PATH
      if normal_string?(path)
        ret = INVALID_PATH unless File.exist?(path)
      else
        ret = ABNORMAL_STRING
      end
      ret
    end

    def valid_fpath_with_message(fname)
      d_puts("valid_fpath_with_message|fname=#{fname}")

      mes = ""
      ret = valid_fpath(fname)
      ret_bool = (ret == VALID_FILE_PATH)

      case ret
      when ABNORMAL_STRING
        mes = "abnormal string|#{fname}"
        @valid = false

        d_puts("1 fname=#{fname}")
        d_caller(0)
      when INVALID_PATH
        mes = "Can't find #{fname}"
        d_caller(0)
        @valid = false

        d_puts("2 fname=#{fname}")
        d_caller(0)
      else
        mes = ""
        d_puts("3 fname=#{fname}")
      end
      RetCode2.new(ret, ret_bool, mes)
    end

    def valid_fname?(fname)
      ret = false
      if normal_string?(fname)
        if File.file?(fname)
          ret = true
        else
          d_puts("FileOpUtils:valid_fname? 2")
        end
      else
        d_puts("FileOpUtils:valid_fname? 1")
      end
      ret
    end

    def valid_readable_fname?(fname)
      ret = false
      ret = true if normal_string?(fname) and File.file?(fname) and File.readable?(fname)
      ret
    end

    def valid_writable_fpath_with_message(fname)
      mes = ""

      ret = valid_fpath(fname)

      ret_bool = (ret == VALID_FILE_PATH)

      case ret
      when ABNORMAL_STRING
        mes = "abnormal string|#{fname}"
        @valid = false
        d_puts("1 fname=#{fname}")
        d_caller(0)
      when INVALID_FILE_PATH
        mes = "Can't find #{fname}"
        d_caller(0)
        @valid = false
        d_puts("2 fname=#{fname}")
        d_caller(0)
      else
        if File.writable?(fname)
          mes = ""
          ret = WRITABLE_FILE_PATH
        else
          mes = "Can't write #{fname}"
          @valid = false
          ret = NOT_WRITABLE_FILE_PATH
          ret_bool = false
          d_puts("3 fname=#{fname}")
          d_caller(0)
        end
      end
      RetCode2.new(ret, ret_bool, mes)
    end

    def valid_writable_fname?(fname)
      ret = false
      if normal_string?(fname)
        if File.file?(fname)
          ret = true if File.writable?(fname)
        else
          unless File.directory?(fname)
            dir, filename = File.split(fname)
            ret = valid_writable_directory?(dir)
          end
        end
      end
      ret
    end

    def valid_readable_directory?(path)
      ret = false
      ret = true if File.directory?(path) && File.readable?(path)
      ret
    end

    def valid_writable_directory?(path)
      ret = false
      ret = true if File.directory?(path) && File.writable?(path)
      ret
    end

    def write_file_with_template(input_file_path, output_file)
      ary = []
      begin
        File.open(input_file_path, "r") do |file|
          while (line = file.gets)
            line.chomp!
            ary << file_content_process(line)
          end
        end
      rescue StandardError => e
        pp e
        pp e.traceback
        @valid = false
      end
      if @valid
        content = ary.join("\n")
        begin
          output_file.write(content)
        rescue StandardError => e
          pp e
          pp e.traceback
          @valid = false
        end
      end
    end

    def rewrite_file(from_path_1, from_path_2, to_path_1, to_path_2)
      d_p("rewrite_file")
      d_p("from_path_1=#{from_path_1}")
      d_p("from_path_2=#{from_path_2}")
      d_p("to_path_1=#{to_path_1}")
      d_p("to_path_2=#{to_path_2}")

      mes = prepare_file_copy(from_path_1, from_path_2, to_path_1, to_path_2)

      puts_no_empty(mes)

      return false unless @valid

      from_path = File.join(from_path_1, from_path_2)
      to_path = File.join(to_path_1, to_path_2)
      ary = []
      begin
        File.open(from_path, "r") do |file|
          while (line = file.gets)
            line.chomp!
            ary << file_content_process(line)
          end
        end
      rescue StandardError => e
        pp e
        pp e.traceback
        @valid = false
      end

      return false unless @valid

      content = ary.join("\n")

      begin
        File.write(to_path, content)
      rescue StandardError => e
        pp e
        pp e.traceback
        @valid = false
      end
    end

    def prepare_file_copy(from_path_1, from_path_2, to_path_1, to_path_2)
      mes = ""

      d_p("prepare_file_copy")
      d_p("from_path_1=#{from_path_1}")
      d_p("from_path_2=#{from_path_2}")
      d_p("to_path_1=#{to_path_1}")
      d_p("to_path_2=#{to_path_2}")

      if prepare_source_dir(from_path_1, from_path_2)
        unless prepare_dest_dir(to_path_1, to_path_2)
          mes = "Can't write #{to_path_1}/#{to_path_1}"
          d_caller(0)
          @valid = false
        end
      else
        mes = "Can't read #{from_path_1}/#{from_path_2}"
        @valid = false
      end

      mes
    end

    def prepare_source_dir(from_path_1, from_path_2)
      state = false
      from_path = File.join(from_path_1, from_path_2)
      if valid_readable_directory?(from_path_1)
        dirname, filename = File.split(from_path)
        state = true if valid_readable_directory?(dirname) && valid_readable_fname?(from_path)
      end
      state
    end

    def prepare_dest_dir(to_path_1, to_path_2)
      state = true
      unless valid_writable_directory?(to_path_1)
        if File.exist?(to_path_1)
          d_caller(0)
          return false
        end

        begin
          FileUtils.mkdir_p(to_path_1)
        rescue StandardError => e
          state = false
          pp e
          pp e.traceback
        end
      end
      unless valid_writable_directory?(to_path_1)
        d_caller(0)
        return false
      end

      to_path = File.join(to_path_1, to_path_2)
      dirname, filename = File.split(to_path)
      unless File.exist?(dirname)
        begin
          FileUtils.mkdir_p(dirname)
        rescue StandardError => e
          state = false
          pp caller(0)
        end
      end

      unless state
        d_caller(0)
        return false
      end

      unless valid_writable_directory?(dirname)
        d_caller(0)
        return false
      end

      if File.file?(to_path) && !valid_writable_fname?(to_path)
        d_caller(0)
        return false
      end

      true
    end

    def copy_file(from_path_1, from_path_2, to_path_1, to_path_2)
      retry_flag = false
      begin
        from_path = File.join(from_path_1, from_path_2)
        to_path = File.join(to_path_1, to_path_2)
        FileUtils.cp(from_path, to_path)
        d_puts("Copy #{from_path} -> #{to_path}")
      rescue StandardError => e
        retry_flag = prepare_file_copy(from_path_1, from_path_2, to_path_1, to_path_2)
      end

      if retry_flag
        begin
          FileUtils.cp(from_path, to_path)
          d_puts("Copy #{from_path} -> #{to_path}")
        rescue StandardError => e
          @valid = false
        end
      end

      d_puts("Don't Copy #{from_path} -> #{to_path}") unless @valid
    end

    def find_file(path, dirname, filename)
      ret = false
      ary = path.split(File::SEPARATOR)
      left = ary.index(dirname)
      d_p(ary)
      d_p(left)
      if left
        sub_ary = ary[(left + 1)..-1]
        ret = true if sub_ary && sub_ary.index(filename)
      end

      ret
    end

    def check_filepath(fname_ary)
      ret = RetCode2.new(ret, false, "")
      mes_ary = []
      fname_ary.each do |fname|
        ret2 = valid_fpath_with_message(fname)
        d_puts("==check_filepath")
        d_puts_no_empty(ret2.mes)
        d_p(ret2)
        if ret2.bool
          ret.ret = fname
          ret.bool = true
          break
        elsif ret2.ret == FileOpUtils::ABNORMAL_STRING
          ret.ret = ret2.ret
          mes_ary << "Can't find common (#{common_fname})"
        end
      end
      ret.mes = mes_ary.join("\n") unless ret.bool
      ret
    end

    def make_fpath_list(fname, parent_dir_ary)
      ary = [fname]
      parent_dir_ary.each do |dir|
        ary << File.join(dir, fname) if dir
      end
      ary
    end

    def reform_filename(fname, add_string)
      path = Pathname(fname)
      basename = path.basename(".*")
      dirname = path.dirname
      extname = path.extname

      dirname.join(basename.to_s + add_string + extname.to_s)
    end

    def determine_encoding(pn)
      encodings = [Encoding::UTF_8, Encoding::EUC_JP, Encoding::Shift_JIS, Encoding::CP932]

      valid_enc = nil
      encodings.each do |enc|
        next if valid_enc

        s = pn.expand_path.read(encoding: enc)
        next unless s.valid_encoding?

        begin
          cs = s.encode(Encoding::CP932)
          valid_enc = enc
        rescue StandardError => e
          #        puts "Conversion Error! #{y}"
          #            puts y
        end
      end

      valid_enc
    end
  end
end
