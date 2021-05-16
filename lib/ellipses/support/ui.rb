# frozen_string_literal: true

module Ellipses
  module Support
    module Color
      # rubocop:disable Layout/SpaceInsideArrayPercentLiteral
      %w[
        black   0
        blue    39
        cyan    14
        green   35
        magenta 200
        orange  214
        red     197
        violet  140
        white   15
        yellow  11
      ].each_slice(2) do |color, code|
        singleton_class.send(:define_method, color) { |string| "\e[38;5;#{code}m#{string}\e[0m" }
      end

      %w[
        bold       1
        dim        2
        underlined 4
        blink      5
        reverse    7
        hidden     8
      ].each_slice(2) do |attr, code|
        singleton_class.send(:define_method, attr) { |string| "\e[#{code}m#{string}\e[0m" }
      end
      # rubocop:enable Layout/SpaceInsideArrayPercentLiteral
    end

    module_function

    def notice(string)
      "#{Color.bold Color.green "✓"}  #{string}"
    end

    def info(string)
      "#{Color.bold Color.green "✓"}  #{Color.dim string}"
    end

    def error(string)
      "#{Color.bold Color.red "✗"}  #{string}"
    end

    def warning(string)
      "#{Color.bold Color.yellow "!"}  #{string}"
    end
  end
end
