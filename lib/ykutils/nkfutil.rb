# -*- coding utf-8 -*-

require "nkf"

module Ykutils
  module NKFUTIL
    CODE_TO_NAME = Hash.new("ASCII")
    CODE_TO_NAME[NKF::JIS] = "JIS"
    CODE_TO_NAME[NKF::EUC] = "EUC"
    CODE_TO_NAME[NKF::SJIS] = "SJIS"
    CODE_TO_NAME[NKF::BINARY] = "BINARY"
    CODE_TO_NAME[NKF::UTF8] = "UTF8" if NKF.const_defined?(:UTF8)

    def self.guess_encoding(str)
      CODE_TO_NAME[NKF.guess(str)]
    end

    class Assoc
      @@hs = {}
      @@config = nil

      def self.set(key, value)
        @@hs[key] = if value
            Assoc.convert(value)
          else
            value
          end
      end

      def self.get(key)
        @@hs[key]
      end

      def self.to_nkf_encoding_format(encoding)
        case encoding
        when "UTF8"
          "w"
        else
          encoding[0, 1]
        end
      end

      def self.config(src_encoding, dest_encoding, misc_option = nil)
        @@config = "-#{dest_encoding.to_s[0, 1].downcase}#{src_encoding.to_s[0, 1].upcase}"
        @@config += " #{misc_option}" unless misc_option.nil?
      end

      def self.auto_config_to_inner(str, misc_option = nil)
        src_encoding = if str
            Assoc.to_nkf_encoding_format(NKFUTIL.guess_encoding(str))
          else
            "A"
          end

        inner_encoding = Assoc.to_nkf_encoding_format(Assoc.get_inner_encoding)
        if inner_encoding != "A"
          @@config = "-#{inner_encoding.downcase}#{src_encoding.upcase}"
          @@config += " #{misc_option}" unless misc_option.nil?
        end
        src_encoding
      end

      def self.auto_config_from_inner(dest_enc, misc_option = nil)
        dest_encoding = Assoc.to_nkf_encoding_format(dest_enc)
        inner_encoding = Assoc.to_nkf_encoding_format(Assoc.get_inner_encoding)
        if inner_encoding != "A"
          @@config = "-#{dest_encoding.downcase}#{inner_encoding.upcase}"
          @@config += " #{misc_option}" unless misc_option.nil?
        end
      end

      def self.convert(str)
        nstr = nil
        unless str.nil?
          if @@config.nil?
            nstr = str
          else
            begin
              nstr = NKF.nkf(@@config, str)
            rescue StandardError => e
              puts e
              puts "========="
              pp caller(0)
            end
          end
        end
        nstr
      end

      def self.get_inner_encoding
        @@inner_encoding = $KCODE == "NONE" ? "ASCII" : $KCODE
      end
    end

    def self.set(key, value)
      Assoc.set(key, value)
    end

    def self.get(key)
      Assoc.get(key)
    end

    def self.convert(str)
      if str.nil?
        ""
      else
        Assoc.convert(str)
      end
    end

    def self.assoc_equal(target, key)
      target == key || target == Assoc.get(key)
    end

    def self.config(src_encoding, dest_encoding, misc_option = nil)
      Assoc.config(src_encoding, dest_encoding, misc_option)
    end

    def self.auto_config_to_inner(str, misc_option = nil)
      Assoc.auto_config_to_inner(str, misc_option)
    end

    def self.auto_config_from_inner(dest_encoding, misc_option = nil)
      Assoc.auto_config_to_inner(dest_encoding, misc_option)
    end

    def puts_sj(line)
      puts NKF.nkf("-Ws -m0", line)
    end

    def puts_u(line)
      puts NKF.nkf("-Sw -m0", line)
    end

    def nkf_utf8_file(infname, outfname)
      File.open(outfname) do |outf|
        File.open(infname) do |file|
          while line = file.gets
            line.chomp!
            oline = NKF.nkf("-w -m0", line)
            outf.printf("%s\n", oline)
          end
        end
      end
    end
  end
end
