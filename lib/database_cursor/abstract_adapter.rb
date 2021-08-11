require "active_support/core_ext/module/delegation"

module DatabaseCursor
  class Adapter
    # Create a new cursor
    # @param relation [ActiveRecord::Relation]
    # @param batch_size [Integer]
    def initialize(relation, batch_size: 1_000)
      @relation = relation
      @batch_size = batch_size
      @name = "cursor_#{SecureRandom.uuid.tr("-", "_")}"
    end

    private

    attr_reader :relation, :batch_size, :name

    delegate :model, :collection, to: :relation

    def sql
      connection.unprepared_statement { relation.to_sql }
    end

    def open
      connection.execute "DECLARE #{name} NO SCROLL CURSOR FOR #{sql}"
    end

    def close
      connection.execute "CLOSE #{name}"
    end

    def fetch
      model.find_by_sql "FETCH #{batch_size} FROM #{name}"
    end

    def fetch_rows
      result = connection.execute "FETCH #{batch_size} FROM #{name}"
      result.to_a
    end

    def fetch_tuples
      result = connection.execute "FETCH #{batch_size} FROM #{name}"
      result.values
    end
  end
end
