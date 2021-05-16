# frozen_string_literal: true

module Ellipses
  module Client
    class Repository
      File = Struct.new :path, :source, :digest, :registered, keyword_init: true do
        def save(all: true)
          return if !registered && !all
          return if digest == (new_digest = Support.digest(*source.lines))

          Support.writelines(path, source.lines)
          warn Support.notice(path)

          self.digest = new_digest
        end
      end

      private_constant :File

      attr_reader :rootdir

      def initialize(rootdir)
        @rootdir = rootdir
        @files   = {}
        @memo    = {}
      end

      def [](path)
        @files[memo(path)].source
      end

      def each(&block)
        @files.values.map(&:source).each(&block)
      end

      def load(loader)
        loader.read.each { |meta| register(meta.source, meta.series) }
      end

      def register(path, *args, **kwargs)
        if @files.key?(key = memo(path))
          return @files[key].tap { |file| file.registered = true }.source
        end

        source = Source.from_file(key, *args, **kwargs)
        file = @files[key] = File.new path:       key,
                                      source:     source,
                                      digest:     Support.digest(*source.lines),
                                      registered: true
        file.source
      end

      def unregister(path)
        return unless @files.key?(key = memo(path))

        @files[key].tap { |file| file.registered = false }.source
      end

      def registered?(path)
        return false unless @files.key?(key = memo(path))

        @files[key].registered
      end

      def save(all: true)
        n = 0

        @files.each_value { |file| file.save(all: all) and (n += 1) }

        n.positive?
      end

      def dump
        meta = Meta.new []

        @files.each do |path, file|
          next unless file.registered
          next unless (source = file.source).series

          meta << Meta::Source.new(source: path, series: source.series)
        end

        meta
      end

      private

      def memo(path)
        @memo[path] ||= Support.deflate_path(path, rootdir)
      end
    end
  end
end
