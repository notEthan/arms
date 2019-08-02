module ARMS
  class MultiCoder
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

    def load(column_data)
      @coders.reverse.inject(column_data) do |data, coder|
        coder.load(data)
      end
    end

    def dump(object)
      @coders.inject(object) do |data, coder|
        coder.dump(data)
      end
    end
  end
end
