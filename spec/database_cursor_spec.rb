# frozen_string_literal: true

RSpec.describe DatabaseCursor do
  it "has a version number" do
    expect(DatabaseCursor::VERSION).not_to be nil
  end

  context "postgresql" do
    let(:count) { rand(10..25) }
    let(:batch_size) { rand(1..25) }

    before do
      Connection.use(:postgresql)

      count.times do |value|
        Foo.create!(value: value)
      end
    end

    it "yields each record" do
      cursor = Foo.cursor(batch_size: batch_size)
      expected = Array.new(count) { be_a(Foo).and(having_attributes(value: _1)) }
      expect { |y| cursor.each(&y) }.to yield_successive_args(*expected)
    end

    it "yields each row" do
      cursor = Foo.cursor(batch_size: batch_size)
      expected = Array.new(count) { hash_including("value" => _1) }
      expect { |y| cursor.each_row(&y) }.to yield_successive_args(*expected)
    end

    it "yields each tuple" do
      cursor = Foo.select(:value).cursor(batch_size: batch_size)
      expected = Array.new(count) { [_1] }
      expect { |y| cursor.each_tuple(&y) }.to yield_successive_args(*expected)
    end
  end
end
