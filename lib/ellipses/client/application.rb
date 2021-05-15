# frozen_string_literal: true

module Ellipses
  module Client
    class Application
      attr_reader :config, :repository, :loader, :server

      def initialize(repository: nil, loader: nil, server: nil, **options)
        @config     = Config.new(**options)
        @repository = repository || Repository.new(config.rootdir)
        @loader     = loader     || MetaFile.new(config.rootdir, config.lockfiles)
        @server     = server     || Server::Application.new(config.paths)
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
        warn Support.warning "No source changed" unless repository.save

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

      class << self
        %i[init init! compile compile! decompile decompile! update].each do |meth|
          define_method(meth) { |*args, **options| new(**options).public_send(meth, *args) }
        end
      end
    end
  end
end
