module Mongo
  module Followable
    def self.mongoid3?
      defined?(Mongoid) && ::Mongoid.const_defined?(:Observer) # deprecated in Mongoid 4.x
    end

    def self.mongoid2?
      defined?(Mongoid) && ::Mongoid.const_defined?(:Contexts) # deprecated in Mongoid 3.x
    end
  end
end