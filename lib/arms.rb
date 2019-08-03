require "arms/version"

module ARMS
  # base class for ARMS errors
  class Error < StandardError
  end

  # a coder which is not a recognized shortcut and/or does not respond to #load and #dump
  class InvalidCoder < Error
    attr_accessor :coder
  end

  # an error loading column data to objects on the model
  class LoadError < Error
  end

  # an error dumping objects from the model to column data
  class DumpError < Error
  end

  # the object passed to a coder shortcut proc, which indicates the model and attribute name
  # and passes optional arguments used to instantiate the coder.
  class ShortcutInvocation
    # the model on which an attribute is being serialized
    attr_accessor :model
    # the name of the attribute being serialized
    attr_accessor :attr_name
    # arguments passed from the shortcut invocation to the coder shortcut proc
    attr_accessor :args
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

  autoload :MultiCoder, 'arms/multi_coder'
end

module ARMS
  module ActiveRecord
    module AttributeMethods
      module Serialization
        # ActiveRecord::Base.arms_serialize takes an attribute name and any number of coders which
        # will be chained to serialize and deserialize between the database column and the model
        # attribute.
        #
        # full documentation is at {ARMS::MultiCoder#initialize}.
        #
        # here are a few example invocations:
        #
        #     # two coders: indifferent hashes, YAML with argument Hash (the object_class)
        #     arms_serialize('preferences', :indifferent_hashes, [YAML, Hash])
        #
        #     # two coders: struct coder with argument Preference (the struct class), JSON coder
        #     MultiCoder.new([[:struct, Preference], :json], attr_name: 'preferences', model: Foo)
        def arms_serialize(attr_name, *coders)
          multi_coder = ARMS::MultiCoder.new(coders, attr_name: attr_name, model: self)
          serialize(attr_name, multi_coder)
        end
      end
    end
  end
end

require 'active_record'

module ActiveRecord
  class Base
    extend ARMS::ActiveRecord::AttributeMethods::Serialization
  end
end
