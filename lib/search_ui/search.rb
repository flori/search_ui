require 'term/ansicolor'

# SearchUI::Search manages interactive console-based searching through an array
# of objects
#
# This class provides an interactive search interface that allows users to
# filter and select objects from a collection based on text input patterns.
# It handles terminal input processing, display updates, and user navigation
# through the search results.
#
# @example
#   SearchUI::Search.new(
#     match: -> pattern { items.select { |item| item.name.include?(pattern) } },
#     query: -> answer, matches, selector { matches[selector]&.name || 'No matches' },
#     found: -> answer, matches, selector { matches[selector] }
#   ).start
class SearchUI::Search
  include Term::ANSIColor
  extend Term::ANSIColor

  # Initializes a new SearchUI::Search instance with the specified parameters.
  #
  # @param match [ Proc ] a procedure that takes a string and returns an array
  #   of matching objects
  # @param query [ Proc ] a procedure that takes the current answer, matches,
  #   and selector index to generate a query result
  # @param found [ Proc ] a procedure that takes the current answer, matches,
  #   jand selector index to determine if a selection has been made
  # @param output [ IO ] the output stream to display the search interface
  #   (defaults to STDOUT)
  # @param prompt [ String ] the prompt template to display during searching
  #   (defaults to 'Search? %s')
  def initialize(
    match:,
    query:,
    found:,
    output: STDOUT,
    prompt: 'Search? %s'
  )
    @match        = match
    @query        = query
    @found        = found
    @output       = output
    @prompt       = prompt
    @selector     = 0
    @max_selector = nil
    @answer       = ''
  end

  # Starts the interactive search interface and handles user input until a
  # selection is made or the process is cancelled.
  #
  # @return [ Object, nil ] returns the selected result object when a selection
  #   is made, or nil if the process is cancelled
  def start
    @output.print reset
    @matches = @match.(@answer)
    @selector = @selector.clamp(0, [ @matches.size - 1, 0 ].max)
    result = @query.(@answer, @matches, @selector)
    loop do
      @output.print clear_screen
      @output.print move_home { @prompt % @answer + ?\n + result }
      case getc
      when true
        @output.print clear_screen, move_home, reset
        if result = @found.(@answer, @matches, @selector)
          return result
        else
          return nil
        end
      when false
        return nil
      end
      @matches = @match.(@answer)
      @selector = @selector.clamp(0, [ @matches.size - 1, 0 ].max)
      result = @query.(@answer, @matches, @selector)
    end
  end

  private

  # Reads and processes a single character input from stdin, handling special
  # key sequences and updating the search state accordingly.
  #
  # This method manages raw terminal input to capture user keystrokes,
  # interpreting control characters and escape sequences for navigation,
  # selection, and editing operations. It temporarily disables terminal echo
  # and sets raw mode to ensure proper input handling.
  #
  # @return [ Boolean, nil ] returns true when the Enter key is pressed to
  #   confirm selection, false when Ctrl+C is pressed to cancel the operation, or
  #   nil for all other inputs
  #   which update the search state and require further processing
  def getc
    print hide_cursor
    system 'stty raw -echo'
    c = STDIN.getc
    system 'stty cooked echo'
    case c
    when "\x03"
      false
    when "\e"
      STDIN.getc == ?[ or return nil
      STDIN.getc =~ /\A([AB])\z/ or return nil
      if $1 == ?A
        @selector -= 1
      else
        @selector += 1
      end
      @selector = [ @selector, 0 ].max
      nil
    when ?\r
      true
    when "\x7f"
      @selector = 0
      @answer.chop!
      nil
    when "\v"
      @selector = 0
      @answer.clear
      nil
    when /\A[\x00-\x1f]\z/
      nil
    else
      @selector = 0
      @answer << c
      nil
    end
  ensure
    print show_cursor
  end
end
