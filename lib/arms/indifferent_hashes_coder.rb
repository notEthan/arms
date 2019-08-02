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
      object
    end
  end
end
