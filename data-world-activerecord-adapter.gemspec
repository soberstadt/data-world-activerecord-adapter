require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = "data-world-activerecord-adapter"
  spec.version       = DataWorldAdapter::VERSION
  spec.authors       = ["Spencer Oberstadt"]
  spec.email         = ["soberstadt@gmail.com"]

  spec.summary       = "Use ActiveRecord to connect with Data.World"
  spec.homepage      = 'https://github.com/soberstadt/data-world-activerecord-adapter'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # this likely works with other and older versions of rails, but I haven't tested it
  spec.add_dependency 'rails', '~> 6.0.0'
end
