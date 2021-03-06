require "active_record"
require "active_cursor"

ActiveRecord::Migration.verbose = false

module ActiveRecord::Tasks::DatabaseTasks
  def self.verbose?
    false
  end
end

module Database
  URL = ENV.fetch("DATABASE_URL", "postgresql://postgres@localhost/active_cursor")

  def self.create
    ActiveRecord::Tasks::DatabaseTasks.create(URL)
  end

  def self.connect
    ActiveRecord::Base.establish_connection(URL)
  end

  def self.migrate
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
  extend ActiveCursor::QueryMethods

  self.abstract_class = true
end

class Foo < Record
end

class Widget < Record
end
