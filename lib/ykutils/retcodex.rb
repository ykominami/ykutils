module Ykutils
  class RetCode
    attr_reader :val, :mes, :ret, :bool

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

    def set_bool(val)
      @bool = val
    end

    def get_bool
      @bool
    end

    def set_mes(val)
      @mes = val
    end

    def set_ret(val)
      @ret = val
    end
  end

  class RetCode2 < RetCode
    attr_reader :val
    attr_accessor :mes, :ret, :bool

    def initialize(ret, bool, mes)
      @val = { "ret" => ret, "bool" => bool, "mes" => mes }
      @ret = ret
      @bool = bool
      @mes = mes
    end
  end
end
