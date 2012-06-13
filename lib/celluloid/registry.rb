require 'thread'

module Celluloid
  # The Registry allows us to refer to specific actors by human-meaningful names
  module Registry
    @@registry = {}
    @@registry_lock = Mutex.new

    # Register an Actor
    def []=(name, actor)
      actor_singleton = class << actor; self; end
      unless actor_singleton.ancestors.include? ActorProxy
        raise TypeError, "not an actor"
      end

      @@registry_lock.synchronize do
        @@registry[name.to_sym] = actor
      end

      actor.mailbox.system_event NamingRequest.new(name.to_sym)
    end

    # Retrieve an actor by name
    def [](name)
      @@registry_lock.synchronize do
        @@registry[name.to_sym]
      end
    end

    # List all registered actors by name
    def registered
      @@registry_lock.synchronize { @@registry.keys }
    end

    # removes and returns all registered actors as a hash of `name => actor`
    # can be used in testing to clear the registry 
    def clear_registry
      hash = nil
      @@registry_lock.synchronize do
        hash = @@registry.dup
        @@registry.clear
      end
      hash
    end
  end
end
