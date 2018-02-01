require 'tilt'
require 'sprockets'
require 'opal/sprockets/processor'

module Opal
  module ERB
    class Processor < ::Opal::Processor
      def initialize_engine
        super
        require_template_library 'opal/erb'
      end

      def evaluate(context, locals, &block)
        compiler = Opal::ERB::Compiler.new(@data, context.logical_path.sub(/#{REGEXP_START}templates\//, ''))
        @data = compiler.prepared_source
        super
      end
    end
  end
end

if Sprockets.respond_to? :register_transformer
  extra_args = [{mime_type: 'application/javascript', silence_deprecation: true}]
else
  extra_args = []
end

Tilt.register 'opalerb', Opal::ERB::Processor
Sprockets.register_engine '.opalerb', Opal::ERB::Processor, *extra_args
