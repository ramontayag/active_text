# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_text/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ["Ramon Tayag"]
  gem.email = ["ramon@tayag.net"]
  gem.description = %q{Aims to be able to read and replace "variables" in text in an active record manner. I don't claim that it behaves exactly like ActiveRecord - that is a much more complex beast than this will ever be.}
  gem.summary = %q{ActiveText : Text as ActiveRecord : Records. Sort of.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "active_text"
  gem.require_paths = ["lib"]
  gem.version       = ActiveText::VERSION

  gem.add_development_dependency(%q<rspec>, ["= 2.11.0"])
end
