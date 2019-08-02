proc { |p| $:.unshift(p) unless $:.any? { |lp| File.expand_path(lp) == p } }.call(File.expand_path('../lib', File.dirname(__FILE__)))

require 'simplecov'
require 'byebug'

# NO EXPECTATIONS
ENV["MT_NO_EXPECTATIONS"] = ''

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class ARMSSpec < Minitest::Spec
end

# register this to be the base class for specs instead of Minitest::Spec
Minitest::Spec.register_spec_type(//, ARMSSpec)

require 'arms'
require_relative 'blog_models'
