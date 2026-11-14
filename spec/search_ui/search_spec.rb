require 'spec_helper'

describe SearchUI::Search do
  let(:height) { 5 }
  let(:items)  { (1..20).map(&:to_s) }

  let(:search) do
    described_class.new(
      height: height,
      match:  -> _answer { items },
      query:  -> _a, _m, _s { '' },
      found:  -> _a, _m, _s { nil }
    )
  end

  def set_state(search, matches, selector)
    search.instance_variable_set(:@matches, matches)
    search.state.selector = selector
  end

  describe '#adjust_offset' do
    it 'keeps offset at 0 when list fits in the viewport' do
      set_state(search, (1..3).map(&:to_s), 2)
      search.send(:adjust_offset)
      expect(search.instance_variable_get(:@offset)).to eq 0
    end

    it 'slides the window down when the selector crosses the bottom edge' do
      set_state(search, items, 4)   # last visible row (0-indexed)
      search.send(:adjust_offset)   # offset still 0
      expect(search.instance_variable_get(:@offset)).to eq 0

      search.state.selector = 5     # crossed the edge
      search.send(:adjust_offset)
      expect(search.instance_variable_get(:@offset)).to eq 1
    end

    it 'slides the window up when the selector crosses the top edge' do
      search.instance_variable_set(:@matches, items)
      search.instance_variable_set(:@offset, 10)
      search.state.selector = 9     # one above the window
      search.send(:adjust_offset)
      expect(search.instance_variable_get(:@offset)).to eq 9
    end

    it 'does not move the window on wobble within the visible range' do
      search.instance_variable_set(:@matches, items)
      search.instance_variable_set(:@offset, 5)
      search.state.selector = 9     # bottom of window (5+5-1=9)
      search.send(:adjust_offset)
      expect(search.instance_variable_get(:@offset)).to eq 5

      search.state.selector = 6     # still inside window
      search.send(:adjust_offset)
      expect(search.instance_variable_get(:@offset)).to eq 5
    end

    it 'clamps offset when the match list shrinks' do
      search.instance_variable_set(:@offset, 15)
      set_state(search, (1..8).map(&:to_s), 0)
      search.send(:adjust_offset)
      expect(search.instance_variable_get(:@offset)).to eq 0
    end
  end

  describe '#viewport' do
    it 'returns the full list and absolute index when list fits' do
      set_state(search, (1..3).map(&:to_s), 1)
      search.send(:adjust_offset)
      slice, relative = search.send(:viewport)
      expect(slice).to eq %w[1 2 3]
      expect(relative).to eq 1
    end

    it 'returns a windowed slice with relative cursor' do
      search.instance_variable_set(:@matches, items)
      search.instance_variable_set(:@offset, 7)
      search.state.selector = 10
      slice, relative = search.send(:viewport)
      expect(slice).to eq %w[8 9 10 11 12]
      expect(relative).to eq 3
    end
  end
end
