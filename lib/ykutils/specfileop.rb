# -*- coding utf-8 -*-

require "yaml"
require "csv"
require "ykutils/treemanagera"
#if RUBY_VERSION >= "1.8.7"
#  require "ykutils/nkfutil19"
#else
#  require "ykutils/nkfutil"
#end
require "ykutils/nkfutil20"
require "ykutils/debugutils"

module Ykutils
  module SpecFileOp
    include DebugUtils
    include NKFUTIL

    def valid?
      @valid
    end

    def open_for_write(fname)
      begin
        fileobj = File.open(fname, "w")
      rescue StandardError => e
        pp e
        pp e.backtrace
        @valid = false
      end
      fileobj
    end

    def dump_yaml_fileobj(obj, fileobj)
      YAML.dump(obj, fileobj)
    rescue StandardError => e
      pp e
      pp e.backtrace
      @valid = false
    end

    def save_yaml_file(obj, fname)
      File.open(fname, "w") do |fileobj|
        YAML.dump(obj, fileobj)
      end
    rescue StandardError => e
      pp e
      pp e.backtrace
      @valid = false
    end

    def load_yaml_file(fname)
      @data = nil
      begin
        @data = YAML.load_file(fname)
      rescue StandardError => e
        pp e
        pp e.backtrace
        @valid = false
      end
      @data
    end

    def parse_yaml_file(fname)
      begin
        @data = YAML.parse_file(fname)
      rescue StandardError => e
        pp e
        pp e.backtrace
        @valid = false
      end
      @data
    end

    def expand_data(data, separator, except_ary = [])
      tm = TreeManager.new
      re = Regexp.new(separator + "([^#{separator[0, 1]}]+)" + separator)

      data.each do |k, v|
        next unless v

        v.scan(re).flatten.each do |it|
          if it
            tm.add(it, k)
            tm.tag(k, it)
          else
            tm.add(nil, k)
          end
        end
      end

      tm.tsort.reverse.each do |k|
        next unless data[k]

        tag = tm.tag(k)
        next unless tag

        tag.each do |it|
          ntag = Regexp.new(separator + it + separator)
          data[k] = data[k].sub(ntag, data[it]) if data[it]
        end
      end

      data.each do |k, v|
        next unless v

        ary = v.scan(re).flatten
        i = 0
        if ary && !ary.empty?
          except_ary.each do |it|
            i += 1 unless ary.index(it)
          end
        end
        if i.positive?
          puts "#{k} fails to exapnd data. value is #{v}"
          @valid = false
        end
      end

      data
    end

    def make_data_complement(item_ary, data, common)
      item_ary.each do |it|
        data[it] = common[it] unless data[it] && (data[it].strip != "")
      end
    end

    def check_data_complement(item_ary, _data)
      mes_ary = []
      item_ary.each do |k|
        unless @data[k]
          mes_ary << "Specify #{k} "
          @valid = false
        end
      end
      mes_ary
    end

    def check_data_complement_print_message(item_ary, data)
      mes_ary = check_data_complement(item_ary, data)
      mes_ary.each do |mes|
        puts mes
      end
    end

    def load_csv_file(fname)
      ary = []
      begin
        CSV.open(fname, "r") do |row|
          next unless row

          ary << row[0]
        end
      rescue StandardError => e
        pp e
        pp e.backtrace
        @valid = false
      end
      ary
    end

    def load_csv_file_ex(fname)
      ary = []
      begin
        CSV.open(fname, "r") do |row|
          next unless row

          ary.concat(row)
        end
      rescue StandardError => e
        pp e
        pp e.backtrace
        @valid = false
      end
      ary
    end

    def load_plain_text_file(fname)
      ary = []

      begin
        ary0 = File.readlines(fname)
        NKFUTIL.auto_config_to_inner(ary0.join)

        ary = ary0.compact.collect do |x|
          if x.nil?
            ""
          else
            NKFUTIL.convert(x)
          end
        end
      rescue StandardError => e
        pp e
        pp e.backtrace
        @valid = false

        ary = []
      end
      ary
    end
  end
end
