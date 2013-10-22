# Blue State Digital Gem

## Usage

```ruby
gem blue_state_digital
```

Configuration:

```ruby

connection = BlueStateDigital::Connection.new(host:'foo.com' api_id: 'bar', api_secret: 'magic_secret')
cons = BlueStateDigital::Constituent.new({firstname: 'Nathan', lastname: 'Woodhull', emails: [{ email: 'woodhull@gmail.com'}]}.merge({connection: connection}))
cons.save
cons.Id # created constituent ID

```

Use the event machine adapter:

```ruby

connection = BlueStateDigital::Connection.new(host:'foo.com' api_id: 'bar', api_secret: 'magic_secret', adapter: :em_synchrony)

```

## CI
[![Build Status](https://secure.travis-ci.org/controlshift/blue_state_digital.png)](http://travis-ci.org/controlshift/blue_state_digital)

