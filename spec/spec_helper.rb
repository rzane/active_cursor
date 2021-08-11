# frozen_string_literal: true

require "yaml"
require "database_cursor"
require "active_record"
require_relative "support/connection"

# Make sure all databases exist
Connection.prepare

# Define a model to be used in tests
class Foo < ActiveRecord::Base
  extend DatabaseCursor::QueryMethods
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
