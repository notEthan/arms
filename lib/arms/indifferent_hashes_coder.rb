module ARMS
  class IndifferentHashesCoder
    def load(column_data)
      if column_data.respond_to?(:to_ary)
        column_data.to_ary.map { |el| load(el) }
      elsif column_data.respond_to?(:to_hash)
        ActiveSupport::HashWithIndifferentAccess.new(column_data).transform_values { |v| load(v) }
      else
        column_data
      end
    end

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
