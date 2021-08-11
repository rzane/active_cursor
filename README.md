# ActiveCursor

This gem adds support for cursors to Active Record. This library only supports
PostgreSQL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_cursor'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_cursor

## Why?

Sometimes you need to process a huge amount of data, but loading the entire
dataset into memory isn't possible.

In those cases, you'll usually reach for Active Record's `find_each` method, which
will only load records in batches.

Unfortunately, `find_each` requires that each record in the dataset has a unique,
integer ID. That's not always possible. Enter cursors.

## Usage

Extend your `ApplicationRecord` with `ActiveCursor::QueryMethods`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  extend ActiveCursor::QueryMethods
end
```

Now, you're ready to start cursing.

```ruby
User.cursor.each { |user| ... }
User.cursor.each_row { |attributes| ... }
User.select(:id, :name).cursor.each_tuple { |id, name| ... }
```

By default, this will load 1,000 records at a time from the database. You can
change that by specifying the batch size:

```ruby
User.cursor(batch_size: 10).each { |user| ... }
```

All methods return enumerables when no block is given, so you can use the full power of Ruby's Enumerable:

```ruby
User.cursor.each.find { |user| user.name == "Rick" }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/active_cursor.
