# frozen_string_literal: true

require_relative "database_cursor/version"
require "active_support/core_ext/module/delegation"

class DatabaseCursor
  module QueryMethods
    def cursor(...)
      DatabaseCursor.new(all, ...)
    end
  end

  def initialize(relation, batch_size: 1_000)
    @relation = relation
    @batch_size = batch_size
  end

  def each(&block)
    return enum_for(__method__) unless block_given?

    iterate do |name|
      records = model.find_by_sql("FETCH #{batch_size} FROM #{name}")
      records.each(&block)
      records.length
    end
  end

  def each_row(&block)
    return enum_for(__method__) unless block_given?

    iterate do |name|
      result = connection.execute("FETCH #{batch_size} FROM #{name}")
      result.each(&block)
      result.ntuples
    end
  end

  def each_tuple(&block)
    return enum_for(__method__) unless block_given?

    iterate do |name|
      result = connection.execute("FETCH #{batch_size} FROM #{name}")
      result.values.each(&block)
      result.ntuples
    end
  end

  private

  attr_reader :relation, :batch_size

  delegate :model, :connection, to: :relation

  def sql
    connection.unprepared_statement { relation.to_sql }
  end

  def iterate
    name = "cursor_#{SecureRandom.uuid.tr("-", "_")}"

    connection.transaction do
      connection.execute("DECLARE #{name} NO SCROLL CURSOR FOR #{sql}")

      begin
        loop until yield(name) < batch_size
      ensure
        connection.execute("CLOSE #{name}")
      end
    end
  end
end
