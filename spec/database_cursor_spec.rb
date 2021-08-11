# frozen_string_literal: true

RSpec.describe DatabaseCursor do
  it "has a version number" do
    expect(DatabaseCursor::VERSION).not_to be nil
  end

  describe "postgresql" do
    before do
      Connection.use(:postgresql)
    end

    it "counts" do
      expect(Foo.count).to eq(0)
      Foo.create!
      expect(Foo.count).to eq(1)
    end

    it "counts again" do
      expect(Foo.count).to eq(0)
      Foo.create!
      expect(Foo.count).to eq(1)
    end
  end
end
