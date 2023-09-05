# -*- encoding: utf-8 -*-
# stub: search_ui 0.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "search_ui".freeze
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2023-09-05"
  s.description = "This library allows a user to search an array of objects\n  interactively in the console by matching the pattern a user inputs to an\n  array of objects and pick one of the remaining objects.".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["search_it".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/search_ui.rb".freeze, "lib/search_ui/search.rb".freeze, "lib/search_ui/version.rb".freeze]
  s.files = [".gitignore".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "bin/search_it".freeze, "lib/search_ui.rb".freeze, "lib/search_ui/search.rb".freeze, "lib/search_ui/version.rb".freeze, "search_ui.gemspec".freeze]
  s.homepage = "http://flori.github.com/search_ui".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "SearchUi -- Search User Interface".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "Library to provide a user interface for searching in a console".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.12.0"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.0"])
    s.add_development_dependency(%q<debugger>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<amatch>.freeze, ["~> 0.0"])
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.12.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.0"])
    s.add_dependency(%q<debugger>.freeze, [">= 0"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.0"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.0"])
    s.add_dependency(%q<amatch>.freeze, ["~> 0.0"])
  end
end
