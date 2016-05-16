# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seeker/version'

Gem::Specification.new do |spec|
  spec.name          = "seeker"
  spec.version       = Seeker::VERSION
  spec.authors       = ["Mike Daley"]
  spec.email         = ["mike@careerqb.com"]
  spec.summary       = %q{Run job searches on multiple job search sites}
  spec.description   = %q{Prototype for build dogpatch job search gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",        "~> 1.6"
  spec.add_development_dependency "rake",           "~> 10.0"
  spec.add_development_dependency "rspec",          "~> 3.2.0"
  spec.add_development_dependency "vcr",            "~> 2.9.3"
  spec.add_development_dependency "webmock",        "~> 1.21.0"         
  
  spec.add_dependency             "httparty",       "~> 0.13.3"
  spec.add_dependency             "activesupport",  "~> 4.2.1"
  spec.add_dependency             "mechanize",      "~> 2.7.4"
  spec.add_dependency             "dotenv",         "~> 2.0.2" 
end
