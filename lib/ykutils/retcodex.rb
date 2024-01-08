module Ykutils
  class RetCode
    attr_reader :val
    attr_accessor :bool, :mes, :ret

    def initialize(obj)
      @val = obj
      @mes = obj["mes"]
      @ret = obj["ret"]
      @bool = obj["bool"]
    end

    def [](key)
      @val[key]
    end

    def to_s
      @bool
    end
  end

  class RetCode2 < RetCode
    attr_reader :val
    attr_accessor :mes, :ret, :bool

    def initialize(ret, bool, mes)
      @val = { "ret" => ret, "bool" => bool, "mes" => mes }
      super(@val)
    end
  end
end
