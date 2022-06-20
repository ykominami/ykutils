module Ykutils
  module DataStructOp
    def exchange(target_ary, hash, item_key, index_key, content)
      v = hash[item_key]
      if v
        target_ary[v[index_key]] = content
      else
        target_ary << content
      end
    end

    def select_array(ary, num, &block)
      ret_ary = []
      if block
        ary.each do |line|
          ret_ary << [line, num] if block.call(line, num)
          num += 1
        end
      else
        ary.each do |line|
          ret_ary << [line, num]
          num += 1
        end
      end
      ret_ary
    end

    def make_array(ary, num, &block)
      ret_ary = []
      if block
        ary.each do |line|
          ary = block.call(line, num)
          ret_ary += ary if ary
          num += 1
        end
      else
        ret_ary = ary
      end

      ret_ary
    end

    def make_hash(ary, num, &block)
      kv_ary = []
      if block
        ary.each do |line|
          ary = block.call(line, num)
          kv_ary += ary if ary
          num += 1
        end
      else
        kv_ary = ary.collect { |line| [line, nil] }.flatten
      end

      Hash[*kv_ary]
    end
  end
end
