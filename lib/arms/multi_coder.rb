module ARMS
  class MultiCoder
    # loads and dumps between database column and model attribute, using any number of coders.
    #
    # the first coder is closest to the loaded model attribute. the last coder is closest to
    # the dumped database column.
    #
    # each coder must respond to #load and #dump. such a coder can be passed directly, or as a
    # shortcut consisting of a key registered with ARMS.register_coder_shortcut and optional
    # arguments (using an array). each of the following is a valid coder (an element of the
    # coders array):
    #
    #     # direct reference to the coder
    #     ::ActiveRecord::Coders::YAMLColumn.new('foo')
    #
    #     # shortcut, equivalent to the above
    #     :yaml
    #
    #     # shortcut passing optional `object_class` argument to yaml coder.
    #     # the first element of this array is the shortcut key, and the remainder
    #     # is arguments passed to instantiate the coder.
    #     [:yaml, Array]
    #
    # here are a few example invocations that instantiate a MultiCoder:
    #
    #     # two coders: indifferent hashes, YAML with argument Hash (the object_class)
    #     MultiCoder.new([:indifferent_hashes, [YAML, Hash]], attr_name: 'preferences', model: Foo)
    #
    #     # two coders: struct coder with argument Preference (the struct class), JSON coder
    #     MultiCoder.new([[:struct, Preference], :json], attr_name: 'preferences', model: Foo)
    #
    # load goes like:
    #
    # database column -> coderN.load -> ... -> coder1.load -> model attribute
    #
    # dump goes like:
    #
    # model attribute -> coder1.dump -> ... -> coderN.dump -> database column
    #
    # @param coders [Array] an array of coders (which respond to #load and #dump) or coder shortcuts
    # @param model [Class] the model on which the attribute is being serialized
    # @param attr_name the attribute name being serialized on the model
    def initialize(coders, model: nil, attr_name: nil)
      @coders = coders.each_with_index.map do |coder, i|
        shortcut_invocation = ShortcutInvocation.new
        shortcut_invocation.model = model
        shortcut_invocation.attr_name = attr_name

        if coder.respond_to?(:to_ary)
          shortcut_invocation.args = coder[1..-1]
          coder = coder[0]
        end

        if ARMS.instance_exec { @coder_shortcuts }.key?(coder)
          ARMS.instance_exec { @coder_shortcuts }[coder].(shortcut_invocation)
        elsif coder.respond_to?(:load) && coder.respond_to?(:dump)
          if shortcut_invocation.args.nil? || shortcut_invocation.args.empty?
            coder
          else
            raise(InvalidCoder.new("given shortcut arguments are not passed to the coder at index #{i} which responds to #load and #dump. coder: #{coder.inspect}; shortcut args: #{shortcut_invocation.args.inspect}").tap { |e| e.coder = coder })
          end
        else
          raise(InvalidCoder.new("given coder at index #{i} is not a recognized shortcut and does not respond to #load and #dump. coder: #{coder.inspect}; shortcut args: #{shortcut_invocation.args.inspect}").tap { |e| e.coder = coder })
        end
      end
    end

    # @param column_data [Object] data hot off the database column
    # @return [Object] loaded (deserialized) data
    def load(column_data)
      @coders.reverse.inject(column_data) do |data, coder|
        coder.load(data)
      end
    end

    # @param object [Object] object on the model attribute
    # @return [Object] dumped (serialized) data
    def dump(object)
      @coders.inject(object) do |data, coder|
        coder.dump(data)
      end
    end
  end
end
