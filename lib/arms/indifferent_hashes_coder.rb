module ARMS
  # ARMS::IndifferentHashesCoder will replace any Hashes in a structure of Arrays and Hashes with ActiveSupport::HashWithIndifferentAccess on load, and convert back to plain hashes on dump.
  class IndifferentHashesCoder
    # @param column_data [Array, Hash, Object] a structure in which Hashes will be replaced with ActiveSupport::HashWithIndifferentAccess
    def load(column_data)
      if column_data.respond_to?(:to_ary)
        column_data.to_ary.map { |el| load(el) }
      elsif column_data.respond_to?(:to_hash)
        ActiveSupport::HashWithIndifferentAccess.new(column_data).transform_values { |v| load(v) }
      else
        column_data
      end
    end

    # @param object [#to_ary, #to_hash, Object] a structure in which ActiveSupport::HashWithIndifferentAccess instances will be replaced with plain Hashes
    def dump(object)
      if object.respond_to?(:to_ary)
        object.to_ary.map { |el| dump(el) }
      elsif object.respond_to?(:to_hash)
        object.to_hash.transform_values { |v| dump(v) }
      else
        object
      end
    end
  end
end
