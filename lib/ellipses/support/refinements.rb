# frozen_string_literal: true

module Ellipses
  module Support
    module Refinements
      module Struct
        module FromHashWithoutBogusKeys
          refine ::Struct.singleton_class do
            def from_hash_without_bogus_keys!(hash, error:)
              bogus = (hash = hash.transform_keys(&:to_sym)).keys.reject { |key| members.include?(key) }
              raise error, "Bogus keys found: #{bogus}" unless bogus.empty?

              new hash.slice(*members)
            end
          end
        end
      end
    end
  end
end
