# frozen_string_literal: true

module Ellipses
  module Client
    class Application
      attr_reader :config, :repository, :loader, :server

      def initialize(loader: nil, repository: nil, server: nil, **options)
        @config     = Config.new(**options)
        @loader     = loader     || MetaFile.new
        @repository = repository || Repository.new(@loader)
        @server     = server     || Server::Application.new(config.paths)
      end

      def init(directory)
        @loader = MetaFile.create(directory)
      end

      def shutdown
        Support::UI.warn 'Nothing changed' unless repository.save

        loader.write(dump) and Support::UI.info('Updated lock file')
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
        repository.each_source { |source| source.recompile(server) }
        shutdown
      end

      def validate!(*)
        raise NotImplementedError
      end

      def dump
        repository.dump
      end

      private

      def init!
        raise Error, 'Must be initialized' unless loader.loaded?

        repository.load(loader)
      end

      class << self
        %i[init compile compile! decompile decompile! update].each do |meth|
          define_method(meth) { |*args, **options| new(**options).public_send(meth, *args) }
        end
      end
    end
  end
end
