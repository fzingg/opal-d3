module D3
  class Map
    include D3::Native

    def get(key)
      result = @native.JS.get(key)
      `result === undefined ? nil : result`
    end
    include Native
    alias_native_chainable :set
    alias_native_chainable :remove
    alias_native_chainable :clear
    alias_native_new :keys
    alias_native_new :values
    alias_native_new :size
    alias_native_new :empty?, :empty
    alias_native_new :has?, :has
    alias_method :[], :get
    alias_method :[]=, :set

    def entries
      @native.JS.entries().map{|o| [`o.key`, `o.value`]}
    end

    def to_h
      `Opal.hash(#{entries})`
    end

    # Should that be reversed to better match ruby and to work with Enumerable?
    # Or just use #to_h if you want ruby interface?
    def each(&block)
      @native.JS.each(block)
      self
    end

    def inspect
      "#<D3::Map: #{ to_h.inspect }>"
    end
  end

  class << self
    def map(object=nil, &block)
      if block_given?
        D3::Map.new(@d3.JS.map(object, proc{|x| yield(x)}))
      elsif object
        D3::Map.new(@d3.JS.map(object))
      else
        D3::Map.new(@d3.JS.map())
      end
    end
  end
end
