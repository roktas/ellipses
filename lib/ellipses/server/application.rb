# frozen_string_literal: true

module Ellipses
  module Server
    class Application
      DEFAULT_PORT = 0

      Instance = Struct.new :uri, :repository, :port, keyword_init: true do
        def to_s
          self.class.ident(uri, port)
        end

        class << self
          def ident(uri, port)
            "#{uri}:#{port || DEFAULT_PORT}"
          end
        end
      end

      attr_reader :paths, :intersperse

      def initialize(paths, intersperse: "\n")
        @paths       = setup_paths(paths)
        @intersperse = intersperse
        @instances   = {}
      end

      def out(uri:, symbols:, port: nil)
        [].tap { |chunks| symbols.each { |symbol| chunks.append(*instance(uri, port).repository[symbol]) } }
      end

      def dump(uri:, symbols:, port: nil)
        Support.intersperse_arrays(out(uri: uri, symbols: symbols, port: port), intersperse).flatten
      end

      def validate(uri)
        raise NotImplementedError
      end

      def available?(uri)
        !scan(uri).nil?
      end

      def available!(uri)
        return if available?(uri)

        raise Error, "Repository not found in path: #{uri}"
      end

      private

      def instance(uri, port = nil)
        ident = Instance.ident(uri, port)
        return @instances[ident] if @instances.key? ident

        directory = scan(uri)
        raise Error, "No repository instance found: #{uri}" unless directory

        instance = Instance.new uri: uri, repository: Repository.load(directory), port: port
        @instances[ident] = instance
      end

      def setup_paths(paths)
        paths = paths.filter_map { |path| Support.dir(path) }.uniq
        raise Error, 'No valid path found' if paths.empty?

        paths
      end

      def scan(uri)
        paths.map { |path| ::File.join(path, uri) }.find { |path| MetaFile.valid?(path) }
      end

      class << self
        def dump(path, *symbols, **kwargs)
          new([Support.dir!(path, error: Error)], **kwargs).dump(uri: '.', symbols: symbols)
        end

        def validate(path, **kwargs)
          new([Support.dir!(path, error: Error)], **kwargs).validate('.')
        end
      end
    end
  end
end
