describe SearchUI::Wrapper do
  let(:value) { 'foo' }

  c = Term::ANSIColor

  let(:sw1) { described_class.new(value, display: c.red { value }) }

  let(:sw2) { described_class.new(value, display: c.blue { value }) }

  it 'stores the wrapped value' do
    expect(sw1.value).to eq value
  end

  it 'returns the custom string when to_s is called' do
    expect(sw1.to_s).to eq c.red { 'foo' }
  end

  it 'falls back to the wrapped object’s to_s if no display given' do
    wrapper = described_class.new(value)
    expect(wrapper.to_s).to eq 'foo'
  end

  it 'delegates methods to the wrapped value (e.g., length)' do
    expect(sw1.length).to eq 3
  end

  it 'compares equal when underlying values are equal' do
    expect(sw1 == sw2).to be true
  end

  it 'is not equal to a different wrapped value' do
    diff_obj = "bar"
    expect(sw1 == described_class.new(diff_obj)).to be false
  end

  context 'equality with other wrappers' do
    it 'is eq' do
      expect(sw1).to eq sw2
    end

    it 'is ==' do
      expect(sw1 == sw2).to eq true
      expect(sw2 == sw1).to eq true
    end

    it 'is eql' do
      expect(sw1).to be_eql sw2
      expect(sw2).to be_eql sw1
    end
  end

  it 'is equal to its original value' do
    expect(sw1).to eq value
    expect(value).to eq sw1
  end
end
