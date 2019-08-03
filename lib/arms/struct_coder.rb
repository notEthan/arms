module ARMS
  class StructCoder
    def initialize(loaded_class, array: false)
      @loaded_class = loaded_class
      # this notes the order of the keys as they were in the json, used by dump_object to generate
      # json that is equivalent to the json/jsonifiable that came in, so that AR's #changed_attributes
      # can tell whether the attribute has been changed.
      @loaded_class.send(:attr_accessor, :arms_object_json_coder_keys_order)
      @array = array
    end

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
