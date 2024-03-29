lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "arms/version"

Gem::Specification.new do |spec|
  spec.name          = "arms"
  spec.version       = ARMS::VERSION
  spec.authors       = ["Ethan"]
  spec.email         = ["ethan@unth.net"]

  spec.summary       = 'Active Record Multiple Serialization'
  spec.description   = 'A library which offers flexible, chained serializion for Active Record'
  spec.homepage      = "https://github.com/notEthan/arms"
  spec.license       = "MIT"

  ignore_files = %w(.gitignore .travis.yml Gemfile test)
  ignore_files_re = %r{\A(#{ignore_files.map { |f| Regexp.escape(f) }.join('|')})(/|\z)}
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  Dir.chdir(File.expand_path('..', __FILE__)) do
    spec.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(ignore_files_re) }
    spec.test_files  = `git ls-files -z test`.split("\x0") + [
      '.simplecov',
    ]
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3", "~> 1.3", ">= 1.3.6" # loosen this in accordance with active_record/connection_adapters/sqlite3_adapter.rb
end
