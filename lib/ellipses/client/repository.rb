# frozen_string_literal: true

module Ellipses
  module Client
    class Repository
      File = Struct.new :path, :source, :digest, :registered, keyword_init: true do
        def save(all: true)
          return if !registered && !all
          return if digest == (new_digest = Support.digest(*source.lines))

          Support.writelines(path, source.lines)
          Support.notice(path)

          self.digest = new_digest
        end
      end

      private_constant :File

      attr_reader :loader

      def initialize(loader)
        @loader = loader
        @files  = {}
        @memo   = {}
      end

      def [](path)
        @files[memo(path)].source
      end

      def each_source
        each { |_, file| yield(file.source) }
      end

      def load(loader)
        Dir.chdir loader.directory do
          loader.read.each { |meta| register_internal(meta.source, Source.from_file(meta.source, meta.series)) }
        end
      end

      def save(all: true)
        n = 0
        each { |_, file| file.save(all: all) and (n += 1) }
        n.positive?
      end

      def dump
        meta = Meta.new []

        each do |path, file|
          next unless file.registered
          next unless (source = file.source).series

          meta << Meta::Source.new(source: path, series: source.series)
        end

        meta
      end

      def register(path, *args, **kwargs)
        if @files.key?(key = memo(path))
          return @files[key].tap { |file| file.registered = true }.source
        end

        register_internal(key, Source.from_file(path, *args, **kwargs))
      end

      def unregister(path)
        return unless @files.key?(key = memo(path))

        @files[key].tap { |file| file.registered = false }.source
      end

      def registered?(path)
        return false unless @files.key?(key = memo(path))

        @files[key].registered
      end

      private

      def memo(path)
        @memo[path] ||= Support.deflate_path(path, loader.directory)
      end

      def each(&block)
        Dir.chdir(loader.directory) { @files.each(&block) }
      end

      def register_internal(key, source)
        @files[key] = File.new path:       key,
                               source:     source,
                               digest:     Support.digest(*source.lines),
                               registered: true

        source
      end
    end
  end
end
