require "test_helper"

class ARMSTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ARMS::VERSION
  end
end

describe 'ActiveRecord::Base.arms_serialize' do
  describe 'serializing to JSON' do
    it 'serializes json with JSON' do
      Blog::Foo.create!(tags_const_json: {'#BlackLivesMatter' => {rank: 1}})
      assert_equal(%q({"#BlackLivesMatter":{"rank":1}}), Blog::UnserializedFoo.last.tags_const_json)
    end
    it 'serializes json with :json' do
      Blog::Foo.create!(tags_sym_json: {'#BlackLivesMatter' => {rank: 1}})
      assert_equal(%q({"#BlackLivesMatter":{"rank":1}}), Blog::UnserializedFoo.last.tags_sym_json)
    end
  end
  describe 'serializing to YAML' do
    it 'serializes yaml with YAML' do
      Blog::Foo.create!(tags_const_yaml: {'#BlackLivesMatter' => {rank: 1}})
      assert_equal(%Q(---\n"#BlackLivesMatter":\n  :rank: 1\n), Blog::UnserializedFoo.last.tags_const_yaml)
    end
    it 'serializes yaml with :yaml' do
      Blog::Foo.create!(tags_sym_yaml: {'#BlackLivesMatter' => {rank: 1}})
      assert_equal(%Q(---\n"#BlackLivesMatter":\n  :rank: 1\n), Blog::UnserializedFoo.last.tags_sym_yaml)
    end
  end
end
