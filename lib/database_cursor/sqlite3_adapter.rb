require_relative "abstract_adapter"

module DatabaseCursor
  class Sqlite3Adapter < AbstractAdapter
    def each
      connection.raw_connection.execute(sql) do |row|
        yield model.instantiate(row.to_h)
      end
    end

    def each_row
      connection.raw_connection.execute(sql) do |row|
        yield row.to_h
      end
    end

    def each_tuple
      connection.raw_connection.execute(sql) do |row|
        yield row.fields.map { |field| row[field] }
      end
    end
  end
end
