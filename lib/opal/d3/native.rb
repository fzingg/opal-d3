require "native"

module Native
  module Helpers
    def aliases_native(native_names)
      native_names.each do |native_name|
        alias_native(native_name.underscore, native_name)
      end
    end
  end
end

module D3
  module Native
    include ::Native
    def initialize(native)
      raise unless native
      @native = native
    end

    def self.included(klass)
      klass.extend ::Native::Helpers
      klass.extend Helpers
    end

    module Helpers
      # This provides ruby style interfaces:
      # obj.foo
      # obj.foo = 1; obj.bar = 2
      # obj.foo(1).bar(2)

      def attributes_d3(native_names)
        native_names.each do |native_name|
          attribute_d3(native_name.underscore, native_name)
        end
      end

      def attribute_d3(ruby_name, js_name=ruby_name)
        eval <<-EOF
          def #{ruby_name}(new_value=`undefined`)
            if `new_value !== undefined`
              new_value = `null` if new_value == nil
              @native.JS.#{js_name}(new_value)
              self
            else
              value = @native.JS.#{js_name}
              `value === null ? nil : value`
            end
          end
          def #{ruby_name}=(new_value)
            new_value = `null` if new_value == nil
            @native.JS.#{js_name}(new_value)
          end
        EOF
      end

      def attributes_d3_block(native_names)
        native_names.each do |native_name|
          attribute_d3_block(native_name.underscore, native_name)
        end
      end
      
      # This provides ruby style and jquery style interfaces,
      # and also block interface:
      # obj.foo
      # obj.foo = 1; obj.bar = 2
      # obj.foo(1).bar(2).buzz{...}
      def attribute_d3_block(ruby_name, js_name=ruby_name)
        eval <<-EOF
          def #{ruby_name}(new_value=`undefined`, &block)
            if block_given?
              @native.JS.#{js_name}(block)
              self
            elsif `new_value !== undefined`
              new_value = `null` if new_value == nil
              @native.JS.#{js_name}(new_value)
              self
            else
              value = @native.JS.#{js_name}
              `value === null ? nil : value`
            end
          end
          def #{ruby_name}=(new_value)
            new_value = `null` if new_value == nil
            @native.JS.#{js_name}(new_value)
          end
        EOF
      end

      def aliases_native_chainable(native_names)
        native_names.each do |native_name|
          alias_native_chainable(native_name.underscore, native_name)
        end
      end
      
      def alias_native_chainable(ruby_name, js_name=ruby_name)
        eval <<-EOF
          def #{ruby_name}(*args)
            `self["native"].#{js_name}.apply(self["native"], Opal.to_a(args))`
            self
          end
        EOF
      end

      def aliases_native_new(native_names)
        native_names.each do |native_name|
          alias_native_new(native_name.downcase, native_name)
        end
      end

      def alias_native_new(ruby_name, js_name=ruby_name)
        eval <<-EOF
          def #{ruby_name}(*args)
            self.class.new( `self["native"].#{js_name}.apply(self["native"], Opal.to_a(args))` )
          end
        EOF
      end
    end
  end
end
