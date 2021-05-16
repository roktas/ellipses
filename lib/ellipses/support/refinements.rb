# frozen_string_literal: true

module Ellipses
  module Support
    module Refinements
      module Struct
        refine ::Struct.singleton_class do
          def from_hash_without_bogus_keys!(hash, error:)
            hash  = hash.transform_keys(&:to_sym)
            clean = hash.slice(*members)
            bogus = hash.keys.reject { |key| members.include?(key) }

            raise error, "Bogus keys found: #{bogus}" unless bogus.empty?

            new clean
          end
        end
      end
    end
  end
end
