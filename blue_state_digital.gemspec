# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "blue_state_digital/version"

Gem::Specification.new do |s|
  s.name        = "blue_state_digital"
  s.version     = BlueStateDigital::VERSION
  s.authors     = ["Nathan Woodhull"]
  s.email       = ["woodhull@gmail.com"]
  s.homepage    = "https://github.com/controlshift/blue_state_digital"
  s.summary     = "Simple wrapper for Blue State Digital."
  s.description = %q{TODO: Write a gem description}
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "httpotato"
end
