module ARMS
  # this is a ActiveRecord serialization class intended to serialize from a Struct class
  # on the loaded ruby side to something JSON-compatible on the dumped database side.
  #
  # This coder relies on `loaded_class`, the Struct class which will be used to instantiate
  # the column data. properties (members) of the loaded class will correspond
  # to keys of the dumped json object.
  #
  # the data may be either a single instance of the loaded class
  # (serialized as one hash) or an array of them (serialized as an
  # array of hashes), indicated by the boolean keyword argument `array`.
  #
  # the column behind the attribute may be an actual JSON column (postgres json
  # or jsonb - hstore should work too if you only have string attributes) or may
  # be a string column with a string serializer after StructCoder.
  class StructCoder
    # @param loaded_class [Class] the Struct class to load
    # @param array [Boolean] whether the column holds an array of Struct instances instead of just one
    def initialize(loaded_class, array: false)
      @loaded_class = loaded_class
      # this notes the order of the keys as they were in the json, used by dump_object to generate
      # json that is equivalent to the json/jsonifiable that came in, so that AR's #changed_attributes
      # can tell whether the attribute has been changed.
      @loaded_class.send(:attr_accessor, :arms_object_json_coder_keys_order)
      @array = array
    end

    # @param data [Hash, Array<Hash>, nil]
    # @return [loaded_class, Array[loaded_class], nil]
    def load(data)
      return nil if data.nil?
      object = if @array
        unless data.respond_to?(:to_ary)
          raise LoadError, "expected array-like column data; got: #{data.class}: #{data.inspect}"
        end
        data.map { |el| load_object(el) }
      else
        load_object(data)
      end
      object
    end

    # @param object [loaded_class, Array[loaded_class], nil]
    # @return [Hash, Array<Hash>, nil]
    def dump(object)
      return nil if object.nil?
      jsonifiable = begin
        if @array
          unless object.respond_to?(:to_ary)
            raise DumpError, "expected array-like attribute; got: #{object.class}: #{object.inspect}"
          end
          object.map do |el|
            dump_object(el)
          end
        else
          dump_object(object)
        end
      end
      jsonifiable
    end

    private

    # @param data [Hash]
    # @return [loaded_class]
    def load_object(data)
      if data.respond_to?(:to_hash)
        data = data.to_hash
        good_keys = @loaded_class.members.map(&:to_s)
        bad_keys = data.keys - good_keys
        unless bad_keys.empty?
          raise LoadError, "expected keys #{good_keys}; got unrecognized keys: #{bad_keys}"
        end
        instance = @loaded_class.new(*@loaded_class.members.map { |m| data[m.to_s] })
        instance.arms_object_json_coder_keys_order = data.keys
        instance
      else
        raise LoadError, "expected instance(s) of #{Hash}; got: #{data.class}: #{data.inspect}"
      end
    end

    # @param object [loaded_class]
    # @return [Hash]
    def dump_object(object)
      if object.is_a?(@loaded_class)
        keys = (object.arms_object_json_coder_keys_order || []) | @loaded_class.members.map(&:to_s)
        keys.map { |member| {member => object[member]} }.inject({}, &:update)
      else
        raise TypeError, "expected instance(s) of #{@loaded_class}; got: #{object.class}: #{object.inspect}"
      end
    end
  end
end
