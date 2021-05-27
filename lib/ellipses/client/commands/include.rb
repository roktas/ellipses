# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Include < Command
        command 'include', argc: (1..)

        def setup
          source, *param.symbols = argv
          param.uri, param.port = source.split(':')

          server.available!(param.uri)
        end

        def call(*)
          server.dump(uri: param.uri, symbols: param.symbols, port: param.port)
        end
      end
    end
  end
end
