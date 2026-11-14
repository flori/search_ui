require 'term/ansicolor'
require 'io/console'
require 'tins'

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
  #   visible slice of matches, the cursor index relative to that slice, and
  #   (in multi mode) a fourth argument — a Hash of picked items. Used to
  #   generate the string representation of the visible results.
  # @param found [ Proc ] a procedure that accepts the current answer, the
  #   full list of matches, and the absolute selector index to determine the
  #   final selected object.
  # @param height [ Integer ] the number of rows to display. Defaults to
  #   `Tins::Terminal.lines - 1` (clamped to >= 0).
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
  # @param picked [ Hash, Array, Set, nil ] initial multi-select picks. A Hash
  #   is merged directly; an Array or Set is converted to `{ item => true }`.
  #   Only meaningful when `multi: true`. Defaults to nil (no pre-picks).
  # @raise [ ArgumentError ] if `picked` is not `nil` and does not respond
  #   to `#to_hash`, `#to_ary`, or `#to_set`.
  def initialize(
    match:,
    query:,
    found:,
    height: (Tins::Terminal.lines - 1).clamp(0..),
    multi:  false,
    output: STDOUT,
    prompt: 'Search? %s',
    state:  nil,
    all:    nil,
    none:   nil,
    picked: nil
  )
    @match        = match
    @query        = query
    @found        = found
    @height       = height
    @offset       = 0
    @output       = output
    @prompt       = prompt
    @multi        = multi
    @state        = state || State.new('', 0)
    @all          = all
    @none         = none
    @picked       = Hash.new(false)
    case
    when picked.nil?
    when picked.respond_to?(:to_hash)
      @picked.update(picked.to_hash)
    when picked.respond_to?(:to_ary)
      @picked.update(picked.to_ary.each_with_object({}) { |k, h| h[k] = true })
    when picked.respond_to?(:to_set)
      @picked.update(picked.to_set.each_with_object({}) { |k, h| h[k] = true })
    else
      raise ArgumentError, 'picked needs to support #to_hash | #to_ary | #to_set'
    end
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
    @matchables  = @match.('').dup
    @matchables.delete(@all) unless @all.nil?
    @matchables.delete(@none) unless @none.nil?
    result = refresh
    loop do
      @output.print clear_screen
      @output.print move_home { @prompt % @state.answer + ?\n + result }
      case getc
      when true
        @output.print clear_screen, move_home, reset
        if @multi
          return @picked.select { _2 }.keys
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
      result = refresh
    end
  end

  private

  # Re-runs the match proc, keeps the selector and scroll offset in sync
  # with the new result set, and renders the visible window.
  #
  # @return [ String ] the rendered results list for the current viewport
  def refresh
    @matches = @match.(@state.answer)
    @state.selector = @state.selector.clamp(0, [ @matches.size - 1, 0 ].max)
    adjust_offset
    slice, relative = viewport
    if @multi
      @query.(@state.answer, slice, relative, @picked)
    else
      @query.(@state.answer, slice, relative)
    end
  end

  # Slides the scroll offset so the selected item is always inside the
  # visible window, using sticky hysteresis: the window only moves when the
  # cursor crosses an edge, never on mere up/down wobble.
  def adjust_offset
    @offset = [ @offset, [ @matches.size - @height, 0 ].max ].min
    @offset = @state.selector if @state.selector < @offset
    @offset = @state.selector - @height + 1 if @state.selector >= @offset + @height
  end

  # Returns the slice of matches for the visible window along with the
  # selector's position relative to that slice.
  #
  # @return [ Array, Integer ] the visible rows and the relative cursor index
  def viewport
    [ @matches[@offset, @height], @state.selector - @offset ]
  end

  # Reads and processes a single character input from STDIN, handling special
  # key sequences and updating the search state accordingly.
  #
  # This method uses `STDIN.raw` (io/console) to capture user keystrokes in
  # raw mode with interrupt handling, interpreting control characters and
  # ANSI escape sequences:
  # - Up/Down arrows: Navigate the result selector by one row.
  # - Home (\e[H, \e[1~, \eOH) / End (\e[F, \e[4~, \eOF): Jump to first / last.
  # - PgUp (\e[5~) / PgDn (\e[6~): Jump by one viewport height.
  # - Enter (`\r`): Confirms the current selection.
  # - Ctrl-Space (`\x00`): In multi mode, toggles selection of the current
  #   match. In single mode, ignored.
  # - Ctrl-C: Raises Interrupt, caught to cancel the search operation.
  # - Ctrl-K (`\v`): Clears the current search answer.
  # - Backspace (`\x7f`): Deletes the last character of the answer.
  # - Note: Any modification to the search answer resets the selector to 0.
  #
  # @return [ Boolean, nil ]
  #   - `true`: The Enter key was pressed to confirm selection.
  #   - `false`: Ctrl-C was pressed to cancel the operation.
  #   - `nil`: Input updated the search state or was ignored.
  def getc
    interrupted = [ Interrupt, Errno::ENOTTY ]
    interrupted << IRB::Abort if defined? IRB::Abort
    print hide_cursor
    STDIN.raw(min: 1, intr: true) do |io|
      c = io.getc
      case c
      when "\e"
        prefix = io.getc
        case prefix
        when ?[
          key = io.getc
          case key
          when ?A
            @state.selector -= 1
          when ?B
            @state.selector += 1
          when ?H
            @state.selector = 0
          when ?F
            @state.selector = [ @matches.size - 1, 0 ].max
          when ?1, ?4, ?5, ?6
            io.getc == ?~ or return nil
            case key
            when ?1
              @state.selector = 0
            when ?4
              @state.selector = [ @matches.size - 1, 0 ].max
            when ?5
              @state.selector -= @height
            when ?6
              @state.selector += @height
            end
          else
            return nil
          end
        when ?O
          key = io.getc
          case key
          when ?H
            @state.selector = 0
          when ?F
            @state.selector = [ @matches.size - 1, 0 ].max
          else
            return nil
          end
        else
          return nil
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
            case
            when !@all.nil? && @all == m
              @matchables.each { @picked[_1] = true }
            when !@none.nil? && @none == m
              @picked.clear
            when @picked[m]
              @picked[m] = false
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
    end
  rescue *interrupted
    false
  ensure
    print show_cursor
  end
end
