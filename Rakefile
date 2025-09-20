# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'search_ui'
  path_module 'SearchUI'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     'Library to provide a user interface for searching in a console'
  description 'This library allows a user to search an array of objects
  interactively in the console by matching the pattern a user inputs to an
  array of objects and pick one of the remaining objects.'

  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.AppleDouble',
    'tags', '.DS_Store', '.yardoc', 'doc'
    package_ignore '.github', '.gitignore'
  readme      'README.md'
  title       "#{path_module} -- Search User Interface"

  executables << 'search_it'

  required_ruby_version '>= 2.0'
  dependency             'tins', '~>1.0'
  dependency             'term-ansicolor', '~>1.0'
  dependency             'amatch', '~>0.0'
  development_dependency 'simplecov', '~>0.0'
  development_dependency 'debug'
  licenses << 'MIT'
end
