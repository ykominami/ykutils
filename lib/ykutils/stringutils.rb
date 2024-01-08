module Ykutils
  module StringUtils
    def nil_to_nullstring(str)
      str || ""
    end

    def get_basename_ext(itx)
      bn0 = itx.basename.to_s
      if RUBY_VERSION > "1.9"
        #      bn0.encode!( "internal" )
        bn0.encode! "UTF-8"
      end
      list = bn0.split(".")
      case list.size
      when 0
        bname = ""
        ext = ""
      when 1
        bname = list[0]
        ext = ""
      when 2
        bname = list[0]
        ext = list[1]
      else
        bname_size = list.size - 1
        bname = list[0, bname_size].join(".")
        ext = list[-1]
      end
      [bname, ext]
    end

    def normal_string?(str)
      ret = false
      if str
        s = str.strip
        ret = true if s != "" && (s =~ %r{^[0-9A-Za-z_:./\-]+$})
      end
      ret
    end

    def get_normalized_string(str)
      ret = ""
      ret = str.strip if str
      ret
    end

    def make_content_from_template(template_ary, tag_value_hash, separator)
      content_ary = []

      reg_hash = {}
      tag_value_hash.each_key do |k|
        reg_hash[k] = Regexp.new(separator + k + separator)
      end

      template_ary.each do |line|
        reg_hash.each do |k, v|
          line = line.sub(v, tag_value_hash[k])
        end
        content_ary << line
      end
      content_ary
    end

    def indent(num)
      n ||= 0
      @indent_hash ||= {}
      @indent_hash[num] ||= " " * n
      @indent_hash[num]
    end

    def print_hier(data, level)
      case data.class.to_s
      when "Hash"
        data.each_value do |v|
          #        puts "#{indent(level)}#{k}|#{v.class} #{if v.class.to_s == 'String' then v.size else '' end }"
          #        puts "#{indent(level)}#{k}|#{v.class}"
          print_hier(v, level + 1)
        end
      when "Array"
        data.each do |v|
          print_hier(v, level + 1)
        end
        # else
        #      puts "#{indent(level)}|#{data.class}"
      end
    end

    def print_hier2(data, level)
      case data.class.to_s
      when "Hash"
        data.each do |k, v|
          #        puts "#{indent(level)}#{k}|#{v.class} #{if v.class.to_s == 'String' then v.size else '' end }"
          str = "#{indent(level)}#{k}|#{v.class}"
          if v.instance_of?(Array)
            num = v.size
            str += "|#{num}"
            "#{str}###################" if num > 1
          end
          #        puts str
          print_hier_2(v, level + 1) if k != "group"
        end
      when "Array"
        data.each do |v|
          print_hier_2(v, level + 1)
        end
        # else
        #      puts "#{indent(level)}|#{data.class}"
      end
    end
  end
end
