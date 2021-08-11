# frozen_string_literal: true

class Foo < ActiveRecord::Base
  extend DatabaseCursor::QueryMethods
end

RSpec.describe DatabaseCursor do
  let(:count) { 14 }
  let(:batch_size) { 5 }
  let(:relation) { Foo.all }
  let(:cursor) { relation.cursor(batch_size: batch_size) }

  before do
    ActiveRecord::Schema.define do
      create_table :foos, force: true do |t|
        t.integer :value, null: false
      end
    end

    count.times do |value|
      Foo.create!(value: value)
    end
  end

  it "has a version number" do
    expect(DatabaseCursor::VERSION).not_to be nil
  end

  describe "#each" do
    it "yields each record" do
      expected = Array.new(count) { be_a(Foo).and(having_attributes(value: _1)) }
      expect { |y| cursor.each(&y) }.to yield_successive_args(*expected)
    end

    it "returns an enumerator when no block is given" do
      expect(Foo).to receive(:find_by_sql).twice.and_call_original
      cursor.each.find { _1.value == 6 }
    end
  end

  describe "#each_row" do
    it "yields each row" do
      expected = Array.new(count) { hash_including("value" => _1) }
      expect { |y| cursor.each_row(&y) }.to yield_successive_args(*expected)
    end
  end

  describe "#each_tuple" do
    let(:relation) { Foo.select(:value) }

    it "yields each tuple" do
      expected = Array.new(count) { [_1] }
      expect { |y| cursor.each_tuple(&y) }.to yield_successive_args(*expected)
    end
  end
end
