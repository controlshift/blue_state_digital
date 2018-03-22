# Blue State Digital Gem

[![Build Status](https://travis-ci.org/controlshift/blue_state_digital.svg?branch=master)](https://travis-ci.org/controlshift/blue_state_digital)

## Usage

```ruby
gem blue_state_digital
```

Configuration:

```ruby
connection = BlueStateDigital::Connection.new(host:'foo.com', api_id: 'bar', api_secret: 'magic_secret')
cons = BlueStateDigital::Constituent.new({firstname: 'George', lastname: 'Washington', emails: [{ email: 'george@washington.com'}]}.merge({connection: connection}))
cons.save
cons.id # created constituent ID
```

Use the event machine adapter:

```ruby
connection = BlueStateDigital::Connection.new(host:'foo.com', api_id: 'bar', api_secret: 'magic_secret', adapter: :em_synchrony)
```

### Unsubscribes

```ruby
connection = BlueStateDigital::Connection.new(host:'foo.com', api_id: 'bar', api_secret: 'magic_secret')
unsub = BlueStateDigital::EmailUnsubscribe.new({email: 'george@washington.com', reason: 'tea in the harbor'}.merge({connection: connection}))
unsub.unsubscribe! # raises on error, returns true on success.
```

### Signup Forms

```ruby
connection = BlueStateDigital::Connection.new(host:'foo.com', api_id: 'bar', api_secret: 'magic_secret')
signup_form = BlueStateDigital::SignupForm.clone(clone_from_id: 3, slug: 'foo', name: 'my new form', public_title: 'Sign Here For Puppies', connection: connection)
signup_form.set_cons_group(2345)
fields = signup_form.form_fields  # returns a list of SignupFormField

# The keys of the field_data hash should match the labels of the signup form's fields
signup_form.process_signup(field_data: {'First Name' => 'George', 'Last Name' => 'Washington', 'Email Address' => 'george@example.com', 'A Custom Field' => 'some custom data'},
                           email_opt_in: true, source: 'foo', subsource: 'bar')
```

### Dataset integration 

[BSD API for uploading Dataset](https://cshift.cp.bsd.net/page/api/doc#---------------------upload_dataset-----------------)
This creates a new personalization dataset from a slug, map_type, and CSV data, or if the supplied slug already exists, replaces the existing dataset. The CSV data can be attached by ```add_data_header``` and ```add_data_row``` methods. ```save``` method will upload the dataset and return true if successful.
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

[BSD API for listing Datasets](https://cshift.cp.bsd.net/page/api/doc#---------------------list_datasets-----------------)
This returns a list of all personalization datasets.
```ruby
connection.datasets.get_datasets
=> [
  {
      "dataset_id":42,
      "slug":"my_dataset",
      "rows":100,
      "map_type":"state"
  },
  {
      "dataset_id":43,
      "slug":"downballot_dataset",
      "rows":50,
      "map_type":"downballot"
  }
]
```

[BSD API for deleting a Dataset](https://cshift.cp.bsd.net/page/api/doc#---------------------delete_dataset-----------------)
This deletes a personalization dataset. 
```ruby
dataset=BlueStateDigital::Dataset.new({dataset_id: 420}.merge(connection: connection))
dataset.delete
```
If there is any error ```delete``` will return ``false``` and the ```errors``` can be inspected for reasons.

### Dataset Map integration 

[BSD API for uploading Dataset Map](https://cshift.cp.bsd.net/page/api/doc#---------------------upload_dataset_map-----------------)
This takes a CSV of dataset map data and creates or updates all of the mappings found in the CSV. The CSV data can be attached by ```add_data_header``` and ```add_data_row``` methods. ```save``` method will upload the dataset and return true if successful.
```ruby
dataset_map=BlueStateDigital::DatasetMap.new({}.merge(connection: connection))
dataset_map.add_data_header(%w(cons_id downballot houseparty))
dataset_map.add_data_row(%w(123456 NJ01 HP01))
dataset_map.add_data_row(%w(123457,NJ02,HP01))
dataset_map.save
```
If there is an error while saving, it will be available via ```dataset_map.errors```

[BSD API for listing Dataset Maps](https://cshift.cp.bsd.net/page/api/doc#---------------------list_dataset_maps-----------------)
This returns a list of all personalization dataset maps. 
```ruby
connection.dataset_maps.get_dataset_maps
=> [
    {
        "map_id":1,
        "type":"state"
    },
    {
        "map_id":2,
        "type":"downballot"
    },
    {
        "map_id":3,
        "type":"houseparty"
    }
]
```

[BSD API for deleting a Dataset Map](https://cshift.cp.bsd.net/page/api/doc#---------------------delete_dataset-----------------)
This deletes a personalization dataset map. 
```ruby
dataset_map=BlueStateDigital::DatasetMap.new({map_id: 111}.merge(connection: connection))
dataset.delete

## CI
[![Build Status](https://secure.travis-ci.org/controlshift/blue_state_digital.png)](http://travis-ci.org/controlshift/blue_state_digital)

