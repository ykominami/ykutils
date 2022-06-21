require "pathname"

module Ykutils
  class OSUtil
    @@os = nil

    def self.runtime
      @@os ||= if Pathname.pwd.to_s =~ %r{^/cygdrive}
          :CYGWIN
        else
          :ELSE
        end
      @@os
    end
  end
end
