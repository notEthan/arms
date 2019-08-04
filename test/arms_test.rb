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
      Blog::UnserializedFoo.create!(tags_const_indifferent_json: %q({"#BlackLivesMatter":{"rank":1,"x":[{"y":"z"}]}}))
      assert_equal({'#BlackLivesMatter' => {'rank' => 1, 'x' => [{'y' => 'z'}]}}, Blog::Foo.last.tags_const_indifferent_json)
      assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Blog::Foo.last.tags_const_indifferent_json)
      assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Blog::Foo.last.tags_const_indifferent_json['#BlackLivesMatter']['x'][0])
    end
  end
  describe 'serializing with indifferent access' do
    it 'serializes yaml with string keys with indifferent access shortcut' do
      Blog::Foo.create!(tags_indifferent_yaml: {'#BlackLivesMatter' => {'rank' => 1}})
      assert_equal(%Q(---\n"#BlackLivesMatter":\n  rank: 1\n), Blog::UnserializedFoo.last.tags_indifferent_yaml)
    end
    it 'serializes yaml with symbol keys with indifferent access shortcut' do
      Blog::Foo.create!(tags_indifferent_yaml: {'#BlackLivesMatter' => {rank: 1}})
      assert_equal(%Q(---\n"#BlackLivesMatter":\n  rank: 1\n), Blog::UnserializedFoo.last.tags_indifferent_yaml)
    end
    it 'serializes json with indifferent access shortcut' do
      Blog::Foo.create!(tags_indifferent_json: {'#BlackLivesMatter' => {'rank' => 1}})
      assert_equal(%q({"#BlackLivesMatter":{"rank":1}}), Blog::UnserializedFoo.last.tags_indifferent_json)
    end
    it 'serializes json with ARMS::IndifferentHashesCoder' do
      Blog::Foo.create!(tags_const_indifferent_json: {'#BlackLivesMatter' => {rank: 1, x: [{y: 'z'}]}})
      assert_equal(%q({"#BlackLivesMatter":{"rank":1,"x":[{"y":"z"}]}}), Blog::UnserializedFoo.last.tags_const_indifferent_json)
    end
  end
  describe 'deserializing to structs' do
    it 'deserializes json array of tags to structs' do
      Blog::UnserializedFoo.create!(tags_ary_struct_json: %q([{"name":"#BlackLivesMatter","rank":1}]))
      tag = Blog::Foo.last.tags_ary_struct_json.last
      assert_equal("#BlackLivesMatter", tag.name)
      assert_equal(1, tag.rank)
      assert_instance_of(Blog::Tag, tag)
    end
    it 'deserializes yaml array of tags to structs' do
      Blog::UnserializedFoo.create!(tags_ary_struct_yaml: %Q(---\n- name: "#BlackLivesMatter"\n  rank: 1\n))
      tag = Blog::Foo.last.tags_ary_struct_yaml.last
      assert_equal("#BlackLivesMatter", tag.name)
      assert_equal(1, tag.rank)
      assert_instance_of(Blog::Tag, tag)
    end
    it 'deserializes json array of tags to structs (tags_ary_struct_inst_json)' do
      Blog::UnserializedFoo.create!(tags_ary_struct_inst_json: %q([{"name":"#BlackLivesMatter","rank":1}]))
      tag = Blog::Foo.last.tags_ary_struct_inst_json.last
      assert_equal("#BlackLivesMatter", tag.name)
      assert_equal(1, tag.rank)
      assert_instance_of(Blog::Tag, tag)
    end
    it 'deserializes yaml array of tags to structs (tags_ary_struct_inst_yaml)' do
      Blog::UnserializedFoo.create!(tags_ary_struct_inst_yaml: %Q(---\n- name: "#BlackLivesMatter"\n  rank: 1\n))
      tag = Blog::Foo.last.tags_ary_struct_inst_yaml.last
      assert_equal("#BlackLivesMatter", tag.name)
      assert_equal(1, tag.rank)
      assert_instance_of(Blog::Tag, tag)
    end
    it 'newest_tag' do
      Blog::UnserializedFoo.create!(newest_tag: %Q({"name":"#arms","rank":5280}))
      foo = Blog::Foo.last
      assert_equal("#arms", foo.newest_tag.name)
      assert_equal(5280, foo.newest_tag.rank)
      assert_instance_of(Blog::Tag, foo.newest_tag)
    end
  end
  describe 'serializing to structs' do
    it 'deserializes json array of tags to structs' do
      Blog::Foo.create!(tags_ary_struct_json: [Blog::Tag.new('#BlackLivesMatter', 1)])
      assert_equal(%q([{"name":"#BlackLivesMatter","rank":1}]), Blog::UnserializedFoo.last.tags_ary_struct_json)
    end
    it 'deserializes yaml array of tags to structs' do
      Blog::Foo.create!(tags_ary_struct_yaml: [Blog::Tag.new('#BlackLivesMatter', 1)])
      assert_equal(%Q(---\n- name: "#BlackLivesMatter"\n  rank: 1\n), Blog::UnserializedFoo.last.tags_ary_struct_yaml)
    end
    it 'deserializes json array of tags to structs (tags_ary_struct_inst_json)' do
      Blog::Foo.create!(tags_ary_struct_inst_json: [Blog::Tag.new('#BlackLivesMatter', 1)])
      assert_equal(%q([{"name":"#BlackLivesMatter","rank":1}]), Blog::UnserializedFoo.last.tags_ary_struct_inst_json)
    end
    it 'deserializes yaml array of tags to structs (tags_ary_struct_inst_yaml)' do
      Blog::Foo.create!(tags_ary_struct_inst_yaml: [Blog::Tag.new('#BlackLivesMatter', 1)])
      assert_equal(%Q(---\n- name: "#BlackLivesMatter"\n  rank: 1\n), Blog::UnserializedFoo.last.tags_ary_struct_inst_yaml)
    end
    it 'newest_tag' do
      Blog::Foo.create!(newest_tag: Blog::Tag.new('#arms', 5280))
      assert_equal(%Q({"name":"#arms","rank":5280}), Blog::UnserializedFoo.last.newest_tag)
    end
  end
  describe 'incorrect invocation' do
    it 'raises when trying to pass arguments to a coder that is not a shortcut' do
      err = assert_raises(ARMS::InvalidCoder) { Blog::Foo.arms_serialize('x', [ARMS::IndifferentHashesCoder.new, 3]) }
      assert_match(%r(given shortcut arguments are not passed to the coder at index 0 which responds to #load and #dump\. coder: #<ARMS::IndifferentHashesCoder.*>; shortcut args: \[3\]), err.message)
    end
    it 'raises when given a coder that is not a coder' do
      err = assert_raises(ARMS::InvalidCoder) { Blog::Foo.arms_serialize('x', "jsonify this pls") }
      assert_equal("given coder at index 0 is not a recognized shortcut and does not respond to #load and #dump. coder: \"jsonify this pls\"; shortcut args: nil", err.message)
    end
  end
end
