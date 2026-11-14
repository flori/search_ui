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

  # Represents the current state of the search interface.
  #
  # @attr answer [ String ] the current input string entered by the user
  # @attr selector [ Integer ] the index of the currently selected match
  State = Struct.new(:answer, :selector)

  # Initializes a new SearchUI::Search instance to manage an interactive
  # console search interface. This method sets up the filtering logic, display
  # formatting, and selection criteria required to drive the search loop, as
  # well as the output stream and prompt.
  #
  # @param match [ Proc ] a procedure that accepts a search pattern string and returns
  #   an array of matching objects.
  # @param query [ Proc ] a procedure that accepts the current answer, the
  #   list of matches, and the current selector index. In multi mode a fourth
  #   argument — a Hash of picked items — is appended so callers can render
  #   selection markers. Used to generate the string representation of the
  #   results list.
  # @param found [ Proc ] a procedure that accepts the current answer, the list of
  #   matches, and the current selector index to determine the final selected object.
  # @param multi [ Boolean ] enable multi-select mode where Ctrl-Space
  #   toggles items in a picked set and Enter returns all picked items as
  #   an Array. Defaults to false.
  # @param output [ IO ] the output stream where the interface will be rendered.
  #   Defaults to STDOUT.
  # @param prompt [ String ] a format string used as the user prompt.
  #   Defaults to 'Search? %s'.
  # @param state [ SearchUI::Search::State, nil ] an initial state object containing
  #   the starting answer and selector position. Defaults to a new State with an
  #   empty answer and selector set to 0.
  def initialize(
    match:,
    query:,
    found:,
    multi:  false,
    output: STDOUT,
    prompt: 'Search? %s',
    state:  nil
  )
    @match        = match
    @query        = query
    @found        = found
    @output       = output
    @prompt       = prompt
    @multi        = multi
    @state        = state || State.new('', 0)
    @picked       = Hash.new(false)
  end

  # Reads the current internal state of the search interface, containing the
  # current input answer and the active selection index.
  #
  # @return [ SearchUI::Search::State ] the current state object tracking
  #   the user's search progress and cursor position
  attr_reader :state

  # Starts the interactive search interface and handles user input until a
  # selection is made or the process is cancelled.
  #
  # @return [ Object, Array, nil ] In single mode, returns the selected result
  #   object or nil if cancelled. In multi mode, returns an Array of picked
  #   items or nil if cancelled.
  def start
    @output.print reset
    @matches = @match.(@state.answer)
    @state.selector = @state.selector.clamp(0, [ @matches.size - 1, 0 ].max)
    result = execute_query(@state.answer, @matches, @state.selector, @picked)
    loop do
      @output.print clear_screen
      @output.print move_home { @prompt % @state.answer + ?\n + result }
      case getc
      when true
        @output.print clear_screen, move_home, reset
        if @multi
          return @picked.keys
        else
          if result = @found.(@state.answer, @matches, @state.selector)
            return result
          else
            return nil
          end
        end
      when false
        return nil
      end
      @matches = @match.(@state.answer)
      @state.selector = @state.selector.clamp(0, [ @matches.size - 1, 0 ].max)
      result = execute_query(@state.answer, @matches, @state.selector, @picked)
    end
  end

  private

  # Invokes the user-supplied `query` proc with the appropriate arity.
  #
  # In multi mode the `picked` Hash is forwarded as a fourth argument so
  # callers can render selection markers; in single mode only three
  # arguments are passed, preserving backward compatibility with existing
  # three-parameter lambdas.
  #
  # @param answer [ String ] the current search input
  # @param matches [ Array ] the current list of matched objects
  # @param selector [ Integer ] the index of the active selection
  # @param picked [ Hash ] the multi-select picked set (forwarded only in
  #   multi mode)
  # @return [ String ] the rendered results list
  def execute_query(answer, matches, selector, picked)
    if @multi
      @query.(answer, matches, selector, picked)
    else
      @query.(answer, matches, selector)
    end
  end

  # Reads and processes a single character input from STDIN, handling special
  # key sequences and updating the search state accordingly.
  #
  # This method manages raw terminal input to capture user keystrokes,
  # interpreting control characters and ANSI escape sequences:
  # - Up/Down arrows: Navigate the result selector.
  # - Enter (`\r`): Confirms the current selection.
  # - Ctrl-Space (`\x00`): In multi mode, toggles selection of the current
  #   match. In single mode, ignored.
  # - Ctrl-C (`\x03`): Cancels the search operation.
  # - Ctrl-K (`\v`): Clears the current search answer.
  # - Backspace (`\x7f`): Deletes the last character of the answer.
  # - Note: Any modification to the search answer resets the selector to 0.
  #
  # It temporarily disables terminal echo and sets raw mode to ensure proper
  # input handling.
  #
  # @return [ Boolean, nil ]
  #   - `true`: The Enter key was pressed to confirm selection.
  #   - `false`: Ctrl-C was pressed to cancel the operation.
  #   - `nil`: Input updated the search state or was ignored.
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
        @state.selector -= 1
      else
        @state.selector += 1
      end
      @state.selector = [ @state.selector, 0 ].max
      nil
    when ?\r
      true
    when "\x7f"
      @state.selector = 0
      @state.answer.chop!
      nil
    when ?\v
      @state.selector = 0
      @state.answer.clear
      nil
    when "\x00"
      if @multi
        if m = @matches[@state.selector]
          if @picked.key?(m)
            @picked.delete(m)
          else
            @picked[m] = true
          end
        end
      end
      nil
    when /\A[\x01-\x1f]\z/
      nil
    else
      @state.selector = 0
      @state.answer << c
      nil
    end
  ensure
    print show_cursor
  end
end
