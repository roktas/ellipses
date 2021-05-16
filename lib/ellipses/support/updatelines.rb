# frozen_string_literal: true

module Ellipses
  module Support
    module_function

    def updatelines(file, lines)
      old = ::File.exist?(file) ? ::File.read(file) : nil
      new = "#{[*lines].join.chomp}\n"

      if old && old == new
        false
      else
        ::File.write(file, new)
        true
      end.tap { |status| yield(status) if block_given? }
    end
  end
end
