# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'search_ui'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "http://flori.github.com/#{name}"
  summary     'Library to provide a user interface for searching in a console'
  description 'This library allows a user to search an array of objects
  interactively in the console by matching the pattern a user inputs to an
  array of objects and pick one of the remaining objects.'

  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.AppleDouble', 'tags', '.byebug_history', '.DS_Store'
  readme      'README.md'
  title       "#{name.camelize} -- Search User Interface"

  executables << 'search_it'

  required_ruby_version '>= 2.0'
  dependency  'tins', '~>1.0'
  dependency 'term-ansicolor', '~>1.0'
  dependency 'amatch', '~>0.0'
  development_dependency 'simplecov', '~>0.0'
  licenses << 'MIT'
end
