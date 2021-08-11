require "active_record"
require "database_cursor"

module Database
  URL = ENV.fetch("DATABASE_URL", "postgresql://postgres@localhost/database_cursor")

  def self.create
    ActiveRecord::Tasks::DatabaseTasks.create(URL)
  end

  def self.connect
    ActiveRecord::Base.establish_connection(URL)
  end

  def self.migrate
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :foos, force: true do |t|
        t.integer :value, null: false
      end

      create_table :widgets, force: true do |t|
        t.integer :value, null: false
        t.string :name, null: false
        t.timestamp :timestamp, null: false
      end
    end
  end
end

class Record < ActiveRecord::Base
  extend DatabaseCursor::QueryMethods

  self.abstract_class = true
end

class Foo < Record
end

class Widget < Record
end
