# -*- encoding: utf-8 -*-
# stub: search_ui 0.0.8 ruby lib

Gem::Specification.new do |s|
  s.name = "search_ui".freeze
  s.version = "0.0.8".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "This library allows a user to search an array of objects\n  interactively in the console by matching the pattern a user inputs to an\n  array of objects and pick one of the remaining objects.".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["search_it".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/search_ui.rb".freeze, "lib/search_ui/search.rb".freeze, "lib/search_ui/version.rb".freeze]
  s.files = [".gitignore".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "bin/search_it".freeze, "lib/search_ui.rb".freeze, "lib/search_ui/search.rb".freeze, "lib/search_ui/version.rb".freeze, "search_ui.gemspec".freeze]
  s.homepage = "https://github.com/flori/search_ui".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "SearchUi -- Search User Interface".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Library to provide a user interface for searching in a console".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 2.6".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.0".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<amatch>.freeze, ["~> 0.0".freeze])
end
