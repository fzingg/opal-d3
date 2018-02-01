module Opal
  module Sprockets

    class PathReader
      def initialize(env, context)
        @env ||= env
        @context ||= context
      end

      def read path
        if path.end_with? '.js'
          context.depend_on_asset(path)
          env[path, bundle: true].to_s
        else
          context.depend_on(path)
          File.open(expand(path), 'rb:UTF-8'){|f| f.read}
        end
      rescue ::Sprockets::FileNotFound
        nil
      end

      def expand path
        env.resolve(path) or
          # Sprockets 3 just returns nil for unknown paths
          raise ::Sprockets::FileNotFound, path.inspect
      end

      def paths
        env.paths
      end

      attr_reader :env, :context
    end

  end
end
