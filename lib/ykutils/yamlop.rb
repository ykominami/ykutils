require "ykutils/specfileop"
require "ykutils/stext"
require "ykutils/datastructop"

module Ykutils
  class YamlOp
    attr_accessor :valid, :yaml, :ofname

    include SpecFileOp
    include DataStructOp

    TEST_ID_NO_VALUE = 0
    TEST_ID_LISTUP_ALL = 1

    def initialize(opts = {}, _argv = [], _debug: false)
      @fname = nil
      @check_flag = opts["check"]
      @ifname = opts["input_file"]
      @ofname = opts["output_file"]
      @reform_flag = opts["reform"]
      @test_id = opts["test_id"]
      @valid = true
      @ptext = []
    end

    def valid?
      @valid
    end

    def exec
      if @reform_flag
        reform
      elsif @test_id.positive?
        case @test_id
        when TEST_ID_LISTUP_ALL
          test_listup
        end
      end

      true
    end

    def test_listup
      import(@ifname)
      puts "###listup_all"
      ary = listup_all
      ary.each do |it|
        puts(it)
      end

      puts "###listup_host"
      ary = listup_host
      ary.each do |it|
        puts(it)
      end

      puts "###listup_domain"
      ary = listup_domain
      ary.each do |it|
        puts(it)
      end
    end

    def load_yaml(fname)
      @yaml = load_yaml_file(fname)
    end

    def load_yaml_ifname
      @yaml = load_yaml_file(@ifname)
    end

    def load(fname)
      ret = false
      if File.file?(fname)
        @fname = fname
        @pstext = StructuredTextForAccount.new
        #    @pstext.load_analyze( fname , "C-#{fname}-#{Time.now.to_i}.txt" )
        @pstext.load_analyze(fname)
        @yaml = load_yaml_file(fname)
        ret = true
      end

      ret
    end

    def yaml2stext(yaml = @yaml)
      #    begin
      yaml_str = YAML.dump(yaml)
      #    puts yaml_str
      #     rescue => ex
      #       pp ex
      #       pp caller(0)
      #       exit 1000
      #     end
      yaml_ary = yaml_str.split("\n")

      @yamlstext = StructuredTextForAccount.new
      @yamlstext.analyze(yaml_ary)
    end

    def sort
      @yamlstext.sort_by(@pstext)
    end

    def import(fname)
      ret = false
      if File.file?(fname) && File.readable?(fname)
        @ptext = load_plain_text_file(fname).collect(&:chomp)
        ret = false
      end
      ret
    end

    def importex(fname)
      ret = import(fname)
      if ret
        @ptext_hash = {}
        @ptext_hash = make_hash(@ptext, 0) do |l, i|
          if l !~ (/^\s/) && l !~ (/^==/)
            key, = l.split(":")
            [key, { "CONTENT" => l, "INDEX" => i }]
          end
        end
        ret = false
      end
      ret
    end

    def listup_all
      @ptext.select { |l| l !~ /^\s/ and l !~ /^#/ }
    end

    def listup_host
      @ptext.select { |l| l !~ /^\s/ and l !~ /^=/ and l !~ /^#/ }
    end

    def listup_domain
      @ptext.grep(/^==/)
    end

    def output_yaml(obj, fname)
      File.open(fname, "w") do |file|
        YAML.dump(obj, file)
      end
    rescue YkutilsError => e
      pp e
      pp e.backtrace
      @valid = false
    end

    def update_yaml(yaml)
      buf = File.read(@ifname)
      File.write(@ofname, buf)
      File.open(@ifname, "w") do |file|
        YAML.dump(yaml, file)
      end
    rescue StandardError => e
      pp e
      pp e.backtrace
      @valid = false
    end

    def dump_to_file(fname)
      File.open(fname, "w") do |file|
        @yamlstext.dump(file)
      end
    rescue YkutilsError => e
      pp e
      pp e.backtrace
      @valid = false
    end

    def dump_ptext_to_file(fname)
      File.open(fname, "w") do |file|
        @ptext.each do |l|
          file.write("#{l}\n")
        end
      end
    rescue YkutilsdError => e
      pp e
      pp e.backtrace
      @valid = false
    end

    def exchange_ptext(key, value)
      @ptext[@ptext_hash[key]["INDEX"]] = value
      @ptext_hash[key]["CONTENT"] = value
    end

    def reform
      ret = importex(@ifname)
      return unless ret

      ary = listup_host.collect do |it|
        key, = it.split(":")
        key
      end
      str = ary.join(" , ")
      new_host_list = "=-HOST_LIST: [#{str}]"
      ary2 = listup_domain.collect do |it|
        key, = it.split(":")
        key
      end
      str2 = ary2.join(" , ")
      new_domain_list = "=-DOMAIN_LIST: [#{str2}]"
      pp "==new_host_list"
      pp new_host_list
      exchange_ptext("=-HOST_LIST", new_host_list)
      exchange_ptext("=-DOMAIN_LIST", new_domain_list)
      dump_ptext_to_file(@ofname)
    end

    def extract_value(ary)
      ary.collect do |x|
        x2 = x
        x.scan(/{([^}]+)}/).each do |y|
          y.each do |z|
            re = Regexp.new(%({#{z}}))
            x2 = x2.gsub(re, @yaml[z])
          end
        end
        x2
      end
    end
  end
end
