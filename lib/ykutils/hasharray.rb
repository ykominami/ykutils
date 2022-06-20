module Ykutils
  class Hasharray < Hash
    def initialize(*args)
      super(*args)
      @ary = super.keys
      #    @ary ||= []
      @ary ||= []
    end

    def []=(key, value)
      super(key, value)
      @ary << key unless @ary.index(key)
    end

    def each(&block)
      @ary.each do |it|
        block.call(it, self[it])
      end
    end

    def keys
      @ary
    end

    def values
      @ary.collect { |it| self[it] }
    end

    def clear
      super
      @ary = []
    end

    def replace(*args)
      super(*args)
      @ary = super.keys
      @ary ||= []
    end

    def delete(ind, &block)
      @ary.delete(ind)

      super
    end

    def delete_if(&block)
      @ary.each do |it|
        @ary.delete(it) if block.call(it, self[it])
      end

      super
    end

    def reject(&block)
      super
    end
  end
end
