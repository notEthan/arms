require "arms/version"

module ARMS
  class Error < StandardError
  end

  @coder_shortcuts = {}

  class << self
    def register_coder_shortcut(key, &coderproc)
      raise(ArgumentError, "already registered shortcut: #{key}") if @coder_shortcuts.key?(key)
      @coder_shortcuts[key] = coderproc
      nil
    end
  end
end
