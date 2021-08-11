require "securerandom"
require_relative "abstract_adapter"

module DatabaseCursor
  class PostgreSQLAdapter < AbstractAdapter
    def each(&block)
      iterate do |name|
        records = fetch_records(name)
        records.each(&block)
        records.length
      end
    end

    def each_row(&block)
      iterate do |name|
        result = fetch_result(name)
        result.each(&block)
        result.ntuples
      end
    end

    def each_tuple(&block)
      iterate do |name|
        result = fetch_result(name)
        result.values.each(&block)
        result.ntuples
      end
    end

    private

    def fetch_records(name)
      model.find_by_sql "FETCH #{batch_size} FROM #{name}"
    end

    def fetch_result(name)
      connection.execute "FETCH #{batch_size} FROM #{name}"
    end

    def iterate
      name = "cursor_#{SecureRandom.uuid.tr("-", "_")}"

      connection.transaction do
        connection.execute "DECLARE #{name} NO SCROLL CURSOR FOR #{sql}"

        begin
          loop until yield(name) < batch_size
        ensure
          connection.execute "CLOSE #{name}"
        end
      end
    end
  end
end
