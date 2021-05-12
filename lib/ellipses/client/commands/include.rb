# frozen_string_literal: true

module Ellipses
  module Client
    module Commands
      class Include < Command
        command 'include', argc: (1..)

        def setup
          uri, *param.symbols = argv
          param.source, param.port = uri.split(':')

          server.available!(param.source)
        end

        def call(*)
          server.dump(name: param.source, symbols: param.symbols, port: param.port)
        end
      end
    end
  end
end
