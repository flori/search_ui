# SearchUI 🔍 - Searching things in console

## Description

A Ruby library for creating interactive console-based search interfaces 🎯

## Documentation

Complete API documentation is available at: [GitHub.io](https://flori.github.io/search_ui/)

## Features

- **Interactive Navigation** 🎮: Arrow key navigation through search results
- **Real-time Filtering** ⚡: Instant search updates as you type
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
