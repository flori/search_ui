# Wrapper around an arbitrary value that:
#
# * Exposes the wrapped object via `value`.
# * Allows you to supply a custom string representation (`display`).
# * Delegates all other method calls straight through to the wrapped value.
#
# This is handy when you want to keep your objects printable in a
# particular colour or format (e.g. with Term::ANSIColor) while still
# behaving like the original object for comparisons, length checks,
# etc.
#
# @example Basic usage
#   wrapper = SearchUI::Wrapper.new('foo', display: '🟢 foo')
#   puts wrapper          # => "🟢 foo"
#   wrapper.length        # => 3 (delegated to the string)
class SearchUI::Wrapper < BasicObject
  # Initializes a new wrapper.
  #
  # @param value [Object] The object you want to wrap.
  # @param display [String, Proc] Custom display string or a callable
  #   receiving the wrapped value (or no args) and returning a display string.
  #   Defaults to `value.to_s`.
  def initialize(value, display: value.to_s)
    @value   = value
    @display = display
  end

  # Returns the wrapped object.
  #
  # @return [Object]
  attr_reader :value

  # Equality comparison.
  #
  # Two wrappers are equal if their underlying values compare equal to the other argument.
  #
  # @param other [Object] The value or another wrapper to compare against.
  # @return [Boolean]
  def ==(other)
    @value == other
  end

  alias eql? ==

  # String representation of the wrapped object.
  #
  # If `display` is a String, it is returned as-is. If it is a callable,
  # it is invoked (passing the wrapped value when arity ≥ 1) and its
  # return value is used. Otherwise falls back to `value.to_s`.
  #
  # @return [String]
  def to_s
    if @display.respond_to?(:call)
      case @display.method(:call).arity
      when 0
        @display.()
      else
        @display.(@value)
      end
    else
      @display
    end.to_s
  end

  alias to_str to_s

  # Delegates any unknown method call to the wrapped value.
  #
  # This makes the wrapper behave like a transparent proxy for most
  # operations (e.g. `length`, `upcase`, etc.).
  #
  # @param a [Array] Method name and arguments.
  # @param o [Hash] Keyword arguments.
  # @yield b Optional block passed to the underlying method.
  def method_missing(*a, **o, &b)
    @value.__send__(*a, **o, &b)
  end
end
