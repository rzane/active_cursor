# frozen_string_literal: true

require_relative "database_cursor/version"
require_relative "database_cursor/postgresql_adapter"
require_relative "database_cursor/sqlite3_adapter"

module DatabaseCursor
  class Error < StandardError; end

  ADAPTERS = {
    "postgresql" => PostgreSQLAdapter,
    "sqlite3" => Sqlite3Adapter,
  }

  module QueryMethods
    def cursor(...)
      adapter = ADAPTERS.fetch(connection_db_config.adapter)
      adapter.new(all, ...)
    rescue KeyError => error
      raise "Unknown adapter: #{error.key}"
    end
  end
end
