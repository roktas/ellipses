# frozen_string_literal: true

require "open3"

module Ellipses
  module Support
    module Shell
      Result = Struct.new :args, :out, :err, :exit_code, keyword_init: true do
        def outline
          out.first
        end

        def ok?
          exit_code&.zero?
        end

        def notok?
          !ok?
        end

        def cmd
          args.join " "
        end
      end

      # Adapted to popen3 from github.com/mina-deploy/mina
      class Runner
        def initialize
          @coathooks = 0
        end

        def run(*args)
          return dummy_result if args.empty?

          out, err, status =
            Open3.popen3(*args) do |_, stdout, stderr, wait_thread|
              block(stdout, stderr, wait_thread)
            end
          Result.new args, out, err, status.exitstatus
        end

        private

        def block(stdout, stderr, wait_thread)
          # Handle `^C`
          trap("INT") { handle_sigint(wait_thread.pid) }

          out = stdout.readlines.map(&:chomp)
          err = stderr.readlines.map(&:chomp)

          [out, err, wait_thread.value]
        end

        def handle_sigint(pid) # rubocop:disable Metrics/MethodLength
          message, signal = if @coathooks > 1
                              ["SIGINT received again. Force quitting...", "KILL"]
                            else
                              ["SIGINT received.", "TERM"]
                            end

          warn
          warn message
          ::Process.kill signal, pid
          @coathooks += 1
        rescue Errno::ESRCH
          warn "No process to kill."
        end
      end

      module_function

      def run(*args)
        Runner.new.run(*args)
      end

      def fake(*args)
        dummy_result(args)
      end

      def dummy_result(args = [])
        Result.new args, [], [], 0
      end
    end
  end
end
