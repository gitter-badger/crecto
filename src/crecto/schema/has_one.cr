module Crecto
  module Schema
    module HasOne
      VALID_HAS_ONE_OPTIONS = [:foreign_key]

      macro has_one(association_name, klass, **opts)
        # puts "has one " + {{association_name.id.stringify}}
      end
    end
  end
end