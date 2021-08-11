module Connection
  extend self

  CONFIG = {
    postgresql: ENV.fetch("POSTGRESQL_URL", "postgresql://postgres@localhost/database_cursor")
  }

  def prepare
    CONFIG.each do |_, url|
      ActiveRecord::Tasks::DatabaseTasks.create(url)
    end
  end

  def use(name)
    ActiveRecord::Base.establish_connection(CONFIG.fetch(name))
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :foos, force: true do |t|
        t.integer :value, default: 0
      end
    end
  end
end
