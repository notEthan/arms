require_relative 'test_helper'

describe ARMS::StructCoder do
  let(:struct) { Struct.new(:foo, :bar) }
  let(:options) { {} }
  let(:struct_coder) { ARMS::StructCoder.new(struct, options) }
  describe 'json' do
    describe 'load' do
      it 'loads nil' do
        assert_nil(struct_coder.load(nil))
      end
      it 'loads a hash' do
        assert_equal(struct.new('bar'), struct_coder.load({"foo" => "bar"}))
      end
      it 'loads something else' do
        assert_raises(ARMS::LoadError) do
          struct_coder.load([[]])
        end
      end
      it 'loads unrecognized keys' do
        assert_raises(ARMS::LoadError) do
          struct_coder.load({"uhoh" => "spaghettio"})
        end
      end
      describe 'array' do
        let(:options) { {array: true} }
        it 'loads an array of hashes' do
          data = [{"foo" => "bar"}, {"foo" => "baz"}]
          assert_equal([struct.new('bar'), struct.new('baz')], struct_coder.load(data))
        end
        it 'loads an empty array' do
          assert_equal([], struct_coder.load([]))
        end
        it 'does not load what is not an array of structs' do
          assert_raises(ARMS::LoadError) { struct_coder.load({"foo" => "bar"}) }
        end
      end
    end
    describe 'dump' do
      it 'dumps nil' do
        assert_nil(struct_coder.dump(nil))
      end
      it 'dumps a struct' do
        assert_equal({"foo" => "x", "bar" => "y"}, struct_coder.dump(struct.new('x', 'y')))
      end
      it 'dumps something else' do
        assert_raises(TypeError) do
          struct_coder.dump(Object.new)
        end
      end
      it 'dumps all the keys of a struct after loading in a partial one' do
        struct = struct_coder.load({'foo' => 'who'})
        assert_equal({'foo' => 'who', 'bar' => nil}, struct_coder.dump(struct))
        struct.bar = 'whar'
        assert_equal({'foo' => 'who', 'bar' => 'whar'}, struct_coder.dump(struct))
      end
      describe 'array' do
        let(:options) { {array: true} }
        it 'dumps an array of structs' do
          structs = [struct.new('x', 'y'), struct.new('z', 'q')]
          assert_equal([{"foo" => "x", "bar" => "y"}, {"foo" => "z", "bar" => "q"}], struct_coder.dump(structs))
        end
        it 'does not dump what is not an array of structs' do
          assert_raises(ARMS::DumpError) { struct_coder.dump(struct.new('z', 'q')) }
        end
      end
    end
  end
end
