# -*- coding utf-8 -*-

require "nkf"

module Ykutils
  module NKFUTIL
    # ASCII-8BIT
    # US-ASCII
    unless CODE_TO_NAME
      CODE_TO_NAME = Hash.new("ASCII")
      CODE_TO_NAME["US-ASCII"] = "ASCII"
      CODE_TO_NAME["stateless-ISO-2022-JP"] = "JIS"
      CODE_TO_NAME["ISO-2022-JP"] = "JIS"
      CODE_TO_NAME["ISO-2022-JP-2"] = "JIS"
      CODE_TO_NAME["EUC-JP"] = "EUC"
      CODE_TO_NAME["eucJP-ms"] = "EUC"
      CODE_TO_NAME["Shift_JIS"] = "SJIS"
      CODE_TO_NAME["Windows-31J"] = "SJIS"
      CODE_TO_NAME["ASCII-8BIT"] = "BINARY"
      CODE_TO_NAME["UTF-8"] = "UTF8"
    end

    begin
      NAME_TO_ENCODING
    rescue StandardError
      NAME_TO_ENCODING = Hash.new("US-ASCII")
      NAME_TO_ENCODING["UTF8"] = "UTF-8"
      NAME_TO_ENCODING["ASCII"] = "US-ASCII"
      NAME_TO_ENCODING["JIS"] = "ISO-2022-JP"
      NAME_TO_ENCODING["EUC"] = "EUC-JP"
      NAME_TO_ENCODING["SJIS"] = "Winodws-31J"
      NAME_TO_ENCODING["BINARY"] = "ASCII-8BIT"
    end

    def self.guess_encoding(str)
      puts "**#{str.encoding}"
      CODE_TO_NAME[str.encoding.to_s]
    end

    class Assoc
      @hs = {}
      @config = nil

      def self.set(key, value)
        @hs[key] = if value
                     Assoc.convert(value)
                     # else
                     #  value
                   end
      end

      def self.get(key)
        @hs[key]
      end

      def self.to_nkf_encoding_format(encoding)
        NAME_TO_ENCODING[encoding]
      end

      def self.config(_src_encoding, dest_encoding, _misc_option = nil)
        @config = dest_encoding
      end

      def self.auto_config_to_inner(str, _misc_option = nil)
        src_encoding = if str
                         Assoc.to_nkf_encoding_format(NKFUTIL.guess_encoding(str))
                       else
                         "US-ASCII"
                       end

        #      inner_encoding = Assoc.to_nkf_encoding_format( Assoc.get_inner_encoding )
        #      if inner_encoding != "US-ASCII"
        #      @config = inner_encoding
        @config = nil
        #      end
        src_encoding
      end

      def self.auto_config_from_inner(dest_enc, _misc_option = nil)
        dest_encoding = Assoc.to_nkf_encoding_format(dest_enc)
        #      inner_encoding = Assoc.to_nkf_encoding_format( Assoc.get_inner_encoding )
        #      if inner_encoding != "US-ASCII"
        #      @config = dest_encoding.downcase
        @config = dest_encoding
        #      end
      end

      def self.convert(str)
        nstr = nil
        unless str.nil?
          if @config.nil?
            nstr = str
          else
            begin
              #            nstr = NKF.nkf( @@config , str )
              nstr = str.encode(@config)
            rescue StandardError => e
              puts e
              puts "========="
              pp caller(0)
            end
          end
        end
        nstr
      end

      #    def Assoc.get_inner_encoding
      #      @@inner_encoding = ($KCODE != "NONE") ? $KCODE : "ASCII"
      #    end
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
      puts line.encod(NAME_TO_ENCODING["SJIS"])
      #    puts NKF.nkf( "-Ws -m0" , line )
    end

    def puts_u(line)
      puts line.encod(NAME_TO_ENCODING["UTF8"])
      puts NKF.nkf("-Sw -m0", line)
    end

    def nkf_utf8_file(infname, outfname)
      File.open(outfname) do |outf|
        File.open(infname) do |file|
          while (line = file.gets)
            line.chomp!
            #          oline = NKF.nkf( "-w -m0" , line )
            oline = line.encode(NAME_TO_ENCODING["UTF8"])
            outf.printf("%s\n", oline)
          end
        end
      end
    end
  end
end
