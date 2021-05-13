# frozen_string_literal: true

module Ellipses
  module Client
    class Application
      DEFAULT_ROOTDIR = "."
      DEFAULT_PATHS   = [".", ENV["ELLIPSES_PATH"], ENV["SRCPATH"]].freeze

      attr_reader :config, :repository, :loader, :server

      def initialize(repository: nil, loader: nil, server: nil, **options, &block)
        @config     = configure(**options, &block)

        @repository = repository || Repository.new(config.rootdir)
        @loader     = loader || LockFile.new(config.rootdir, config.lockfiles)
        @server     = server || Server::Application.new(config.paths)
      end

      def rootdir
        config.rootdir
      end

      def init
        loader.touch

        repository.load(loader)
      end

      def init!
        raise Error, "Must be initialized" unless loader.exist?

        init
      end

      def shutdown
        if repository.save.zero?
          warn
          warn Support.warning "No source changed"
          warn
        end

        loader.write(dump) and warn Support.info("Updated lock file")
      end

      def compile(file)
        init!

        repository.register(file).recompile(server)
      end

      def compile!(file)
        compile(file)
        shutdown
      end

      def decompile(file)
        init!

        return unless repository.registered?(file)

        repository[file].decompile

        repository.unregister(file)
      end

      def decompile!(file)
        decompile(file)
        shutdown
      end

      def update
        init!

        repository.each { |source| source.recompile(server) }

        shutdown
      end

      def validate!(*)
        raise NotImplementedError
      end

      def dump
        repository.dump
      end

      private

      def configure(**options)
        config = OpenStruct.new options.compact

        config.rootdir ||= DEFAULT_ROOTDIR
        config.paths     = DEFAULT_PATHS.dup if !config.paths || config.paths.empty?

        yield(config) if block_given?

        config.rootdir = Support.dir!(config.rootdir, error: Error)
        config.paths.compact!

        config
      end

      class << self
        %i[init init! compile compile! decompile decompile! update].each do |meth|
          define_method(meth) { |*args, **options| new(**options).public_send(meth, *args) }
        end
      end
    end
  end
end
