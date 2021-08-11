require "active_support/core_ext/module/delegation"

module DatabaseCursor
  class AbstractAdapter
    # Create a new cursor
    # @param relation [ActiveRecord::Relation]
    # @param batch_size [Integer]
    def initialize(relation, batch_size: 1_000)
      @relation = relation
      @batch_size = batch_size
      @name = "cursor_#{SecureRandom.uuid.tr("-", "_")}"
    end

    def each(&block)
      iterate do
        records = fetch_records
        records.each(&block)
        records.length
      end
    end

    def each_row(&block)
      iterate do
        result = fetch_result
        result.each(&block)
        result.ntuples
      end
    end

    def each_tuple(&block)
      iterate do
        result = fetch_result
        result.values.each(&block)
        result.ntuples
      end
    end

    private

    attr_reader :relation, :batch_size, :name

    delegate :model, :connection, to: :relation

    def sql
      connection.unprepared_statement { relation.to_sql }
    end

    def open
      connection.execute "DECLARE #{name} NO SCROLL CURSOR FOR #{sql}"
    end

    def close
      connection.execute "CLOSE #{name}"
    end

    def fetch_records
      model.find_by_sql "FETCH #{batch_size} FROM #{name}"
    end

    def fetch_result
      connection.execute "FETCH #{batch_size} FROM #{name}"
    end

    def iterate
      connection.transaction do
        open

        begin
          loop do
            break if yield < batch_size
          end
        ensure
          close
        end
      end
    end
  end
end
