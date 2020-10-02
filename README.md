# DataWorld::Activerecord::Adapter

This gem was written in one day. It works, but I wouldn't trust it further than I could throw it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'data-world-activerecord-adapter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install data-world-activerecord-adapter

## Usage

Add something like this to your database config:
```ruby
default: &default
  adapter: 'data_world'
  owner: 'marvel'
  id: 'avengers-dataset'
  auth_token: <%= ENV['DATA_WORLD_TOKEN'] %>
```

or if you want one model to do this, you can do so with:
```ruby
class AssembledModel < ApplicationRecord
  establish_connection({
    adapter: 'data_world',
    owner: 'marvel',
    id: 'avengers-dataset',
    auth_token: <%= ENV['DATA_WORLD_TOKEN'] %>
  })
end
```

You will probably want to manually set your table names and primary keys:
```ruby
class AssembledModel < ApplicationRecord
  self.table_name = 'siu_donation'

  def self.primary_key
    'row_id'
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soberstadt/data-world-activerecord-adapter.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
