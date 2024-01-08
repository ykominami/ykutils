module Ykutils
  class BasicLines
    def initialize(line_ary)
      @line_ary = line_ary
    end

    def line
      @line_ary.shift if @line_ary.size > -1
    end
  end

  class Lines
    def initialize(line_ary)
      @lines = BasicLines.new(line_ary)
      @line_stack = []
      @status = nil

      setup
    end

    def setup; end

    def line
      @line_stack.shift if @line_stack.size > -1
    end

    def output_f(fname)
      return unless fname

      File.open(fname, "w") do |file|
        @line_stack.each do |it|
          file.write(it.to_s)
        end
      end
    end
  end

  class FtpOpLines < BasicLines
  end

  # class AccountLines < BasicLines
  class AccountLines < Lines
    HOST_ACCOUNT_START = 10
    HOST_ACCOUNT = 11
    HOST_ACCOUNT_END = 12
    DOMAIN_ACCOUNT_START = 20
    DOMAIN_ACCOUNT = 21
    DOMAIN_ACCOUNT_END = 22
    SEPARATOR = 30
    ETC = 100

    def setup
      while (line = @lines.line)
        next if line.strip == ""

        case line
        when /^---/
          case @status
          when HOST_ACCOUNT_START, HOST_ACCOUNT
            @line_stack.push({ "STATUS" => HOST_ACCOUNT_END,
                               "CONTENT" => nil })
          when DOMAIN_ACCOUNT_START, DOMAIN_ACCOUNT
            @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT_END,
                               "CONTENT" => nil })
          end

          @line_stack.push({ "STATUS" => SEPARATOR,
                             "CONTENT" => line })
          @status = SEPARATOR
        when /^\s/
          case @status
          when HOST_ACCOUNT_START, HOST_ACCOUNT
            @line_stack.push({ "STATUS" => HOST_ACCOUNT,
                               "CONTENT" => line })
            @status = HOST_ACCOUNT
          when HOST_ACCOUNT_END
            puts("error!")
            puts(line)
            @line_stack.push({ "STATUS" => HOST_ACCOUNT,
                               "CONTENT" => line })
            @status = HOST_ACCOUNT
          when DOMAIN_ACCOUNT_START, DOMAIN_ACCOUNT
            @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT,
                               "CONTENT" => line })
            @status = DOMAIN_ACCOUNT
          when DOMAIN_ACCOUNT_END
            puts("error!")
            puts(line)
            @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT,
                               "CONTENT" => line })
            @status = DOMAIN_ACCOUNT
          else
            @line_stack.push({ "STATUS" => ETC,
                               "CONTENT" => line })
            @status = ETC
          end
        when /^==/
          case @status
          when HOST_ACCOUNT_START, HOST_ACCOUNT
            @line_stack.push({ "STATUS" => HOST_ACCOUNT_END,
                               "CONTENT" => nil })
          when DOMAIN_ACCOUNT_START, DOMAIN_ACCOUNT
            @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT_END,
                               "CONTENT" => nil })
          end
          @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT_START,
                             "CONTENT" => line })
          @status = DOMAIN_ACCOUNT_START
        else
          case @status
          when HOST_ACCOUNT_START, HOST_ACCOUNT
            @line_stack.push({ "STATUS" => HOST_ACCOUNT_END,
                               "CONTENT" => nil })
          when DOMAIN_ACCOUNT_START, DOMAIN_ACCOUNT
            @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT_END,
                               "CONTENT" => nil })
          end
          @line_stack.push({ "STATUS" => HOST_ACCOUNT_START,
                             "CONTENT" => line })
          @status = HOST_ACCOUNT_START
        end
      end

      i = @line_stack.size - 1
      seeking = true
      while (i >= 0) && seeking
        case @line_stack[i]["STATUS"]
        when DOMAIN_ACCOUNT_START, DOMAIN_ACCOUNT
          @line_stack.push({ "STATUS" => DOMAIN_ACCOUNT_END,
                             "CONTENT" => nil })
          seeking = false
        when HOST_ACCOUNT_START, HOST_ACCOUNT
          @line_stack.push({ "STATUS" => HOST_ACCOUNT_END,
                             "CONTENT" => nil })
          seeking = false
        when ETC
          seeking = true
        else
          seeking = false
        end
        i -= 1
      end
    end
  end
end
