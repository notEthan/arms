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
  describe 'deserializing with indifferent access' do
    it 'deserializes yaml with string keys with indifferent access shortcut' do
      Blog::UnserializedFoo.create!(tags_indifferent_yaml: %Q(---\n"#BlackLivesMatter":\n  rank: 1\n))
      assert_equal({'#BlackLivesMatter' => {'rank' => 1}}, Blog::Foo.last.tags_indifferent_yaml)
      assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Blog::Foo.last.tags_indifferent_yaml)
    end
    it 'deserializes yaml with symbol keys with indifferent access shortcut' do
      Blog::UnserializedFoo.create!(tags_indifferent_yaml: %Q(---\n"#BlackLivesMatter":\n  :rank: 1\n))
      assert_equal({'#BlackLivesMatter' => {'rank' => 1}}, Blog::Foo.last.tags_indifferent_yaml)
      assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Blog::Foo.last.tags_indifferent_yaml)
    end
    it 'deserializes json with indifferent access shortcut' do
      Blog::UnserializedFoo.create!(tags_indifferent_json: %q({"#BlackLivesMatter":{"rank":1}}))
      assert_equal({'#BlackLivesMatter' => {'rank' => 1}}, Blog::Foo.last.tags_indifferent_json)
      assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Blog::Foo.last.tags_indifferent_json)
    end
    it 'deserializes json with ARMS::IndifferentHashesCoder' do
      Blog::UnserializedFoo.create!(tags_const_indifferent_json: %q({"#BlackLivesMatter":{"rank":1}}))
      assert_equal({'#BlackLivesMatter' => {'rank' => 1}}, Blog::Foo.last.tags_const_indifferent_json)
      assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Blog::Foo.last.tags_const_indifferent_json)
    end
  end
end
