require "active_support/core_ext/module/delegation"

module DatabaseCursor
  class AbstractAdapter
    def initialize(relation, batch_size: 1_000)
      @relation = relation
      @batch_size = batch_size
    end

    def each
      raise NotImplementedError
    end

    def each_row
      raise NotImplementedError
    end

    def each_tuple
      raise NotImplementedError
    end

    private

    attr_reader :relation, :batch_size

    delegate :model, :connection, to: :relation

    def sql
      connection.unprepared_statement { relation.to_sql }
    end
  end
end
