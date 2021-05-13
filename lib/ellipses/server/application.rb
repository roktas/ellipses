# frozen_string_literal: true

module Ellipses
  module Server
    class Application
      DEFAULT_PORT = 0

      Instance = Struct.new :name, :source, :port, keyword_init: true do
        def to_s
          self.class.ident(name, port)
        end

        class << self
          def ident(name, port)
            "#{name}:#{port || DEFAULT_PORT}"
          end
        end
      end

      attr_reader :paths, :intersperse

      def initialize(paths, intersperse: "\n")
        @paths       = setup_paths(paths)
        @intersperse = intersperse
        @instances   = {}
      end

      def out(name:, symbols:, port: nil)
        [].tap { |chunks| symbols.each { |symbol| chunks.append(*instance(name, port).source[symbol]) } }
      end

      def dump(name:, symbols:, port: nil)
        Support.intersperse_arrays(out(name: name, symbols: symbols, port: port), intersperse).flatten
      end

      def validate(name)
        raise NotImplementedError
      end

      def available?(name)
        !scan(name).nil?
      end

      def available!(name)
        return if available?(name)

        raise Error, "Source not found in path: #{name}"
      end

      private

      def instance(name, port = nil)
        ident = Instance.ident(name, port)
        return @instances[ident] if @instances.key? ident

        directory = scan(name)
        raise Error, "No source instance found: #{name}" unless directory

        instance = Instance.new name: name, source: Source.load(directory), port: port
        @instances[ident] = instance
      end

      def setup_paths(paths)
        paths = paths.filter_map { |path| Support.dir(path) }.uniq
        raise Error, "No valid path found" if paths.empty?

        paths
      end

      def scan(name)
        paths.map { |path| ::File.join(path, name) }.find { |path| SourceFile.valid?(path) }
      end

      class << self
        def dump(path, *symbols, **kwargs)
          new([Support.dir!(path, error: Error)], **kwargs).dump(name: ".", symbols: symbols)
        end

        def validate(path, **kwargs)
          new([Support.dir!(path, error: Error)], **kwargs).validate(".")
        end
      end
    end
  end
end
