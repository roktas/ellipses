# frozen_string_literal: true

require 'date'

module Ellipses
  module Client
    module Commands
      class Timestamp < Command
        command 'timestamp', argc: 1

        def call(*)
          timestamp = DateTime.now.strftime(*argv)
          input.map { |line| line.empty? ? timestamp : "#{timestamp} #{line}" }
        end
      end
    end
  end
end
