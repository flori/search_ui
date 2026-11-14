# SearchUI 🔍 - Searching things in console

## Description

A Ruby library for creating interactive console-based search interfaces 🎯

## Documentation

Complete API documentation is available at: [GitHub.io](https://flori.github.io/search_ui/)

## Features

- **Interactive Navigation** 🎮: Arrow key navigation through search results
- **Real-time Filtering** ⚡: Instant search updates as you type
- **Multi-Select** 📋: Tab toggles items, Enter returns all picked
- **Flexible Configuration** 🔧: Customizable matching, display, and selection logic
- **Terminal-aware** 🖥️: Properly handles terminal input and display management
- **Minimal Dependencies** 📦: Lightweight implementation using standard Ruby libraries

## Installation

Add this gem to your Gemfile:

```ruby
gem 'search_ui'
```

And install it using Bundler:

```bash
bundle install
```

Or install the gem directly:

```bash
gem install search_ui
```

## Usage

### Library Usage

For programmatic usage, create a custom search interface:

```ruby
require 'search_ui'

items = ['apple', 'banana', 'cherry', 'date']

result = SearchUI::Search.new(
  match: ->(pattern) { items.select { |item| item.include?(pattern) } },
  query: ->(answer, matches, selector) {
    matches.each_with_index.map do |match, i|
      if i == selector
        "→ #{match}"
      else
        "  #{match}"
      end
    end.join("\n")
  },
  found: ->(answer, matches, selector) { matches[selector] }
).start

puts "Selected: #{result}"
```

#### Multi-Select

Pass `multi: true` to collect multiple items before returning. The `query`
proc additionally receives a fourth argument — a `picked` Hash — so you can
render a visual marker (e.g. `✔`) on already-selected entries.

**Keys:**

| Key         | Action                                          |
|-------------|-------------------------------------------------|
| Arrow Up/Dn | Navigate the list                               |
| Tab         | Toggle selection of the current entry           |
| Enter       | Confirm and return all picked items as an Array |
| Ctrl-C      | Abort and return `nil`                          |

```ruby
require 'search_ui'

result = SearchUI::Search.new(
  match: ->(pattern) {
    %w[apples bananas cherries dates figs grapes].select do |f|
      pattern.empty? || f.include?(pattern)
    end
  },
  query: ->(answer, matches, selector, picked) {
    matches.each_with_index.map do |m, i|
      cursor = i == selector ? '→' : ' '
      mark   = picked[m] ? '✔' : ' '
      "#{cursor} #{mark} #{m}"
    end.join("\n")
  },
  found: ->(answer, matches, selector) { matches[selector] },
  multi:   true,
  picked:  ['bananas'],
  prompt:  'Pick fruit? %s [Tab=toggle, Enter=done, ^C=abort]'
).start

puts "Picked: #{result.inspect}"
```

### Command Line Tool

The `search_it` binary provides a ready-to-use search interface:

```bash
# Search through command-line arguments 🚀
./bin/search_it apple banana cherry

# Search through a file 📄
./bin/search_it -f items.txt
```

## Author

[Florian Frank](mailto:flori@ping.de) 👨‍💻

## License

[MIT License](./LICENSE) 📄
