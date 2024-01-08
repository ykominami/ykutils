# -*- coding utf-8 -*-

require "ykutils/debugutils"
require "ykutils/lines"
require "ykutils/specfileop"
require "ykutils/datastructop"
require "filex"

module Ykutils
  class StructuredText
    attr_reader :main_ary, :main_hash, :item_ary

    include SpecFileOp
    include DataStructOp
    include DebugUtils

    def initialize(debug: false)
      @text = nil
      @fname = nil
      @text_ary = []

      debug_utils_init
      debug(debug)
    end

    def load_analyze(fname, subfname = nil)
      #    puts_current_method
      #    puts "-0 fname=#{fname}"

      @fname = fname
      @text_ary = load(fname)
      #    @text_ary.each do |x| puts x end
      analyze(@text_ary, subfname)
    end

    def load(fname)
      load_plain_text_file(fname).collect(&:chomp)
    end

    def analyze(line_ary, subfname = nil); end

    def dump_to_file(fname)
      FileX.open(fname, "w") do |file|
        @text_ary.each do |l|
          file.write("#{l}\n")
        end
      end
    rescue StandardError => e
      pp e
      pp e.backtrace
      @valid = false
    end
  end

  class StructuredTextForFtpOp < StructuredText
    def analyze(line_ary, fname = nil)
      lines = FtpOpLines.new(line_ary)
      lines.output_f(fname)

      analyze_sub(lines)
    end
  end

  class StructuredTextForAccount < StructuredText
    attr_reader :main_host_ary, :main_host_hash, :main_domain_ary, :main_domain_hash, :main_sep_ary,
                :main_sep_hash, :main_host_item_ary

    def initialize
      super()
      @main_host_item_ary = []

      @main_sep_ary = []
      @main_sep_hash = {}

      @main_host_ary = []
      @main_host_hash = {}

      @main_domain_ary = []
      @main_domain_hash = {}
    end

    def analyze(line_ary, fname = nil)
      lines = AccountLines.new(line_ary)
      lines.output_f(fname)

      analyze_sub(lines)
    end

    def analyze_sub(lines)
      host = StructuredTextForAccountOneLayerHost.new
      domain = StructuredTextForAccountOneLayerDomain.new

      while (line = lines.get_line)
        case line["STATUS"]
        when AccountLines::HOST_ACCOUNT_START, AccountLines::HOST_ACCOUNT, AccountLines::HOST_ACCOUNT_END
          key, value = line["CONTENT"].split(":") if line["CONTENT"]
          key&.strip!
          value&.strip!
          host.analyze(line["STATUS"], line, key, value, @main_host_ary, @main_host_hash)
        when AccountLines::DOMAIN_ACCOUNT_START, AccountLines::DOMAIN_ACCOUNT, AccountLines::DOMAIN_ACCOUNT_END
          key, value = line["CONTENT"].split(":") if line["CONTENT"]
          key&.strip!
          value&.strip!
          domain.analyze(line["STATUS"], line, key, value, @main_domain_ary, @main_domain_hash)
        when AccountLines::SEPARATOR
          key, value = line["CONTENT"].split(":") if line["CONTENT"]

          @main_sep_ary << key
          @main_sep_hash[key] = { "TITLE" => key }
        else
          puts("Error")
          puts(line["CONTENT"])
        end
      end
      @main_host_item_ary |= host.item_ary
    end

    def sort_by(other)
      diff_main_host_ary = @main_host_ary - other.main_host_ary
      diff_main_domain_ary = @main_domain_ary - other.main_domain_ary
      n_main_sep_hash = {}
      n_main_host_ary = []
      n_main_host_hash = {}
      n_main_domain_ary = []
      n_main_domain_hash = {}

      unless other.main_sep_ary.empty?
        @main_sep_ary |= other.main_sep_ary
        @main_sep_hash |= n_main_sep_hash
      end

      main_host_item_ary = other.main_host_item_ary | @main_host_item_ary

      other.main_host_ary.each do |it|
        sort_by_sub(it, @main_host_hash, main_host_item_ary, n_main_host_hash, n_main_host_ary)
      end

      diff_main_host_ary.each do |it|
        sort_by_sub(it, @main_host_hash, main_host_item_ary, n_main_host_hash, n_main_host_ary)
      end

      other.main_domain_ary.each do |it|
        sort_by_sub_for_array(it, @main_domain_hash, n_main_domain_hash, n_main_domain_ary)
      end

      diff_main_domain_ary.each do |it|
        sort_by_sub_for_array(it, @main_domain_hash, n_main_domain_hash, n_main_domain_ary)
      end

      @main_host_ary = n_main_host_ary
      @main_host_hash = n_main_host_hash
      @main_domain_ary = n_main_domain_ary
      @main_domain_hash = n_main_domain_hash
    end

    def sort_by_sub(itx, item_hash, item_ary, n_hash, n_ary)
      h = item_hash[itx]
      return unless h

      n_ary << itx
      title = h["TITLE"]
      hash = h["CONTENT"]
      ary = []
      if hash
        item_ary.each do |ai|
          v = hash[ai]
          ary << ai if v
        end
      end
      n_hash[itx] = { "TITLE" => title, "META" => ary, "CONTENT" => hash }
    end

    def sort_by_sub_for_array(itx, item_hash, n_hash, n_ary)
      h = item_hash[itx]
      return unless h

      n_ary << itx
      title = h["TITLE"]
      ary = h["META"]
      hash = h["CONTENT"]

      n_hash[it] = { "TITLE" => title, "META" => ary, "CONTENT" => hash }
    end

    def dump(file = nil)
      dump_ary = []
      dump_ary += dump_sub(@main_sep_ary, @main_sep_hash)
      dump_ary += dump_sub(@main_host_ary, @main_host_hash)
      dump_ary += dump_sub_for_array(@main_domain_ary, @main_domain_hash)

      str = dump_ary.join("\n")

      if file
        begin
          file.write(str)
          file.write("\n")
        rescue StandardError => e
          pp e
          pp e.backtrace
          @valid = false
        end
      end
      str
    end

    def dump_sub(ary, hash)
      dump_ary = []
      ary.each do |it|
        h = hash[it]
        next unless h

        item_ary = h["META"]
        title = h["TITLE"]
        item_hash = h["CONTENT"]
        dump_ary << title

        next unless item_ary

        item_ary.each do |subit|
          dump_ary << item_hash[subit] if item_hash[subit]
        end
      end
      dump_ary
    end

    def dump_sub_for_array(ary, hash)
      dump_ary = []
      ary.each do |it|
        dump_ary += hash[it]["CONTENT"]
      end
      dump_ary
    end
  end

  class StructuredTextForAccountOneLayer
    attr_accessor :item_ary

    def initialize
      @item_ary = []
      @ary = []
      @hash = {}
      @title = ""
    end
  end

  class StructuredTextForAccountOneLayerDomain < StructuredTextForAccountOneLayer
    def initialize
      super
      @line_ary = []
    end

    def analyze(status, line, key, _value, main_line_ary, main_line_hash)
      case status
      when AccountLines::DOMAIN_ACCOUNT_START
        key.sub!(/^==/, "")
        @title = line["CONTENT"]
        @line_ary << line["CONTENT"]
      when AccountLines::DOMAIN_ACCOUNT
        @line_ary << line["CONTENT"]
      when AccountLines::DOMAIN_ACCOUNT_END
        main_line_ary << @title
        main_line_hash[@title] = { "TITLE" => @title, "CONTENT" => @line_ary }
        @title = ""
        @line_ary = []
      end
    end
  end

  class StructuredTextForAccountOneLayerHost < StructuredTextForAccountOneLayer
    def analyze(status, line, key, _value, main_ary, main_hash)
      case status
      when AccountLines::HOST_ACCOUNT_START
        @hash[key] = line["CONTENT"]
        @title = line["CONTENT"]
      when AccountLines::HOST_ACCOUNT
        @ary << key
        @hash[key] = line["CONTENT"]
      when AccountLines::HOST_ACCOUNT_END
        main_ary << @title
        main_hash[@title] = { "TITLE" => @title, "CONTENT" => @hash, "META" => @ary }

        @item_ary |= @ary
        @ary = []
        @hash = {}
        @title = ""
      end
    end
  end

  class StructuredTextForSimple < StructuredText
    class Item
      attr_reader :name, :contents

      def initialize(name)
        @name = name
        @contents = []
      end

      def add(content)
        @contents << content
      end
    end

    def initialize
      super()
      @item_ary = {}
    end

    def event
      value = nil
      line = @line_ary.shift

      if line
        content = line.strip
        if content.empty?
          ret = :EMPTY_LINE
          value = ""
        elsif content =~ /^-(.*)/
          title = Regexp.last_match(1)
          if title.empty?
            ret = :EMPTY_TITLE_LINE
            value = ""
          else
            ret = :TITLE_LINE
            value = title
          end
        else
          ret = :NON_EMPTY_LINE
          value = content
        end
      else
        ret = :EOF
      end

      [ret, value]
    end

    def make_next_state_table
      @next_state = {}
      @next_state[:NONE] = {}
      @next_state[:NONE][:EMPTY_LINE] = :NONE
      @next_state[:NONE][:TITLE_LINE] = :ITEM
      @next_state[:NONE][:EMPTY_TITLE_LINE] = :END
      @next_state[:NONE][:NON_EMPTY_LINE] = :BAD
      @next_state[:ITEM] = {}
      @next_state[:ITEM][:EMPTY_LINE] = :ITEM
      @next_state[:ITEM][:TITLE_LINE] = :ITEM
      @next_state[:ITEM][:EMPTY_TITLE_LINE] = :END
      @next_state[:ITEM][:NON_EMPTY_LINE] = :ITEM
      @next_state[:END] = {}
      @next_state[:END][:EMPTY_LINE] = :END
      @next_state[:END][:TITLE_LINE] = :BAD
      @next_state[:END][:EMPTY_TITLE_LINE] = :BAD
      @next_state[:END][:NON_EMPTY_LINE] = :END
    end

    def get_next_state(state, event)
      if state == :BAD
        :BAD
      else
        @next_state[state][event]
      end
    end

    def analyze(line_ary, _subfname = nil)
      @line_ary = line_ary
      make_next_state_table
      # :NONE
      # :ITEM
      # :END
      # :BAD

      # :EMPTY_LINE
      # :TITLE_LINE
      # :EMPTY_TITLE_LINE
      # :NON_EMPTY_LINE
      state = :NONE
      event = get_event

      @item_ary = []
      item = nil
      while (state != :BAD) && (event[0] != :EOF)
        case state
        when :NONE, :ITEM
          procx
        else
          case event[0]
          when :EMPTY_LINE, :TITLE_LINE, :EMPTY_TITLE_LINE, :NON_EMPTY_LINE
            item.add(event[1])
          end
        end

        state = get_next_state(state, event[0])
        event = get_event
      end

      @item_ary
    end

    def procx
      case event[0]
      when :EMPTY_LINE, :TITLE_LINE
        @item_ary << (Item.new(event[1]))
      when :EMPTY_TITLE_LINE
        @item_ary << (Item.new(""))
      when :NON_EMPTY_LINE
        item.add(event[1])
      end
    end
  end
end
