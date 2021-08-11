require "bundler/setup"
require "gruff"
require "benchmark"
require "memory_profiler"
require_relative "spec/support/database"

Database.create
Database.connect
Database.migrate

COUNTS = (1..5).map { _1 * 100_000 }
LABELS = (1..5).to_h { [_1 - 1, _1] }
TIME = Hash.new { |h, k| h[k] = [] }
MEMORY = Hash.new { |h, k| h[k] = [] }

def seed(count)
  Widget.delete_all
  Widget.connection.execute <<~SQL
    INSERT INTO widgets (value, name, timestamp)
    SELECT generate_series(0, #{count}), gen_random_uuid(), CURRENT_TIMESTAMP;
  SQL
end

def to_megabytes(bytes)
  (bytes.to_f / 1_000_000).round(2)
end

def measure(name, &block)
  memory = MemoryProfiler.report do
    TIME[name] << Benchmark.realtime(&block)
  end

  MEMORY[name] << to_megabytes(memory.total_allocated_memsize)
end

def chart(data, name:, unit:, filename:)
  chart = Gruff::Line.new
  chart.labels = LABELS
  chart.title = name
  chart.y_axis_label = unit
  chart.x_axis_label = "Records (x100,000)"

  data.each do |name, values|
    chart.data(name, values)
  end

  chart.write(filename)
end

COUNTS.each do |count|
  puts count
  seed(count)

  puts "* to_a"
  measure "to_a" do
    Widget.all.each {}
  end

  puts "* pluck"
  measure "pluck" do
    Widget.pluck(:id, :value, :name, :timestamp)
  end

  puts "* find_each"
  measure "find_each" do
    Widget.find_each {}
  end

  puts "* cursor.each"
  measure "cursor.each" do
    Widget.cursor.each {}
  end

  puts "* cursor.each_row"
  measure "cursor.each_row" do
    Widget.cursor.each_row {}
  end

  puts "* cursor.each_tuple"
  measure "cursor.each_tuple" do
    Widget.cursor.each_tuple {}
  end
end

FileUtils.mkdir_p "assets"
chart TIME, name: "Time", unit: "Seconds", filename: "assets/time.png"
chart MEMORY, name: "Allocated Memory", unit: "Megabytes", filename: "assets/memory.png"