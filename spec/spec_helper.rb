# frozen_string_literal: true

require "yaml"
require "database_cursor"
require "active_record"

DATABASE_URL = ENV.fetch("DATABASE_URL", "postgresql://postgres@localhost/database_cursor")

# Silence migrations
ActiveRecord::Migration.verbose = false

# Create the database
ActiveRecord::Tasks::DatabaseTasks.create(DATABASE_URL)

# Connect to the database
ActiveRecord::Base.establish_connection(DATABASE_URL)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
