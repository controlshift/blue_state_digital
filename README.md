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

### Dataset integration 
[BSD API for uploading Dataset](https://cshift.cp.bsd.net/page/api/doc#---------------------upload_dataset-----------------)

This method creates a new personalization dataset from a slug, map_type, and CSV data, or if the supplied slug already exists, replaces the existing dataset. 

```ruby
dataset=BlueStateDigital::Dataset.new({slug: "downballot_dataset",map_type:"downballot"}.merge(connection: connection))
dataset.add_data_header(%w(index house house_link senate senate_link))
dataset.add_data_row(%w(NJ01 Elect\ Camille\ Andrew http://camilleandrew.com Elect\ Bob\ Smith http://bobsmith.com))
dataset.add_data_row(%w(NJ02 Elect\ David\ Kurkowski http://davidforcongress.com Elect\ Joe\ Jim http://joejim.com))
dataset.save
```
If there is an error while saving, it will be available via ```dataset.errors```
```ruby
dataset=BlueStateDigital::Dataset.new({map_type:"downballot"}.merge(connection: connection))
dataset.save
=> false
dataset.errors.full_messages
=> ["slug can't be blank"]
```

## CI
[![Build Status](https://secure.travis-ci.org/controlshift/blue_state_digital.png)](http://travis-ci.org/controlshift/blue_state_digital)

