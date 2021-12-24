# frozen_string_literal: true

module Ellipses
  module Client
    class Application
      attr_reader :loader, :paths, :repository

      def initialize(loader: nil, repository: nil, paths: nil)
        @loader     = loader || MetaFile.new
        @paths      = locate(paths)
        @repository = repository || Repository.new(@loader, @paths)
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
        repository.register(file).recompile
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
        repository.each_source(&:recompile)
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

      def locate(paths)
        environment            = %w[ELLIPSES_PATH SRCPATH].find { |env| ENV.key? env }
        paths_from_environment = environment ? ENV[environment].split(':') : []

        [*(paths || []), loader.directory, *paths_from_environment].compact.uniq.select { |path| File.directory?(path) }
      end

      class << self
        %i[init compile compile! decompile decompile! update].each do |meth|
          define_method(meth) { |*args, **kwargs| new(**kwargs).public_send(meth, *args) }
        end
      end
    end
  end
end
