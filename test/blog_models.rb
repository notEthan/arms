require 'logger'
module Blog
  logpath = Pathname.new('log/test.log')
  FileUtils.mkdir_p(logpath.dirname)
  -> (logger) { define_singleton_method(:logger) { logger } }.(::Logger.new(logpath))
  logger.level = ::Logger::INFO
end

require 'active_record'
ActiveRecord::Base.logger = Blog.logger
dbpath = Pathname.new('tmp/blog.sqlite3')
FileUtils.mkdir_p(dbpath.dirname)
dbpath.unlink if dbpath.exist?
ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database  => dbpath,
})

ActiveRecord::Schema.define do
  create_table :foos do |table|
    table.column :tags_const_json, :string
    table.column :tags_const_yaml, :string
    table.column :tags_sym_json, :string
    table.column :tags_sym_yaml, :string
    table.column :tags_indifferent_json, :string
    table.column :tags_indifferent_yaml, :string
    table.column :tags_const_indifferent_json, :string
    table.column :tags_ary_struct_json, :string
    table.column :tags_ary_struct_yaml, :string
    table.column :tags_ary_struct_inst_json, :string
    table.column :tags_ary_struct_inst_yaml, :string
    table.column :newest_tag, :string
  end
end

module Blog
  Tag = Struct.new(:name, :rank)

  class Foo < ActiveRecord::Base
    arms_serialize :tags_const_json, JSON
    arms_serialize :tags_const_yaml, YAML
    arms_serialize :tags_sym_json, :json
    arms_serialize :tags_sym_yaml, :yaml
    arms_serialize :tags_indifferent_json, :indifferent_hashes, :json
    arms_serialize :tags_indifferent_yaml, :indifferent_hashes, :yaml
    arms_serialize :tags_const_indifferent_json, ARMS::IndifferentHashesCoder.new, JSON
    arms_serialize :tags_ary_struct_json, [:struct, Blog::Tag, array: true], :json
    arms_serialize :tags_ary_struct_yaml, [:struct, Blog::Tag, array: true], :yaml
    arms_serialize :tags_ary_struct_inst_json, ARMS::StructCoder.new(Blog::Tag, array: true), :json
    arms_serialize :tags_ary_struct_inst_yaml, ARMS::StructCoder.new(Blog::Tag, array: true), :yaml
    arms_serialize :newest_tag, [:struct, Blog::Tag], :json
  end
  class UnserializedFoo < ActiveRecord::Base
    self.table_name = 'foos'
  end
end
