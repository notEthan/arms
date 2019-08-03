require "arms/version"

module ARMS
  # base class for ARMS errors
  class Error < StandardError
  end

  # an error loading column data to objects on the model
  class LoadError < Error
  end

  # an error dumping objects from the model to column data
  class DumpError < Error
  end

  @coder_shortcuts = {}

  class << self
    # adds a shortcut which can be used with ActiveRecord::Base.arms_serialize. the key is usually
    # a symbol, but may be anything. the given block is called by arms_serialize with an
    # ARMS::ShortcutInvocation object, and must result in a coder.
    #
    # @yieldparam shortcut_invocation [ARMS::ShortcutInvocation]
    # @yieldreturn [#load, #dump] a coder which responds to #load and #dump
    def register_coder_shortcut(key, &coderproc)
      raise(ArgumentError, "already registered shortcut: #{key}") if @coder_shortcuts.key?(key)
      @coder_shortcuts[key] = coderproc
      nil
    end
  end
end
