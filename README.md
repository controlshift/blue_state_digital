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

### External Contribution integration 

[BSD API for adding External Contribution](https://cshift.cp.bsd.net/page/api/doc#-----------------add_external_contribution-------------)
Given necessary information to record a contribution, this will process an external contribution the same way that the offline contribution upload tool works. If a constituent does not exist for the given information, one will be created. If a matching constituent already exists, standard de-duping will apply. 
```ruby
contrib = BlueStateDigital::Contribution.new({
  external_id:'UNIQUE_ID_111111111', 
  firstname:'Jane',
  lastname:'Smith',
  transaction_dt:'2012-12-31 23:59:59',
  transaction_amt:20,
  cc_type_cd:'vs'
}.merge(connection: connection)
)
contrib.save
=>true
```
Parameters which can be set are
```ruby
:external_id,
:prefix,:firstname,:middlename,:lastname,:suffix,
:transaction_dt,:transaction_amt,:cc_type_cd,:gateway_transaction_id,
:contribution_page_id,:stg_contribution_recurring_id,:contribution_page_slug,
:outreach_page_id,:source,:opt_compliance,
:addr1,:addr2,:city,:state_cd,:zip,:country,
:phone,:email,
:employer,:occupation,
:custom_fields
``` 
If there is an error when saving, ```save``` will return ```false``` and the ```contrib.errors``` object will contain the error messages for inspection.

[BSD API for listing Contribution](https://cshift.cp.bsd.net/page/api/doc#-----------------get_contributions-------------)
Given a set of filters, this call will return a list of contribution records that fall in the range of the specified filters.
```ruby
connection.contributions.get_contributions({date:'ytd'})
connection.contributions.get_contributions({date:'ytd',type:'all',source:'apples,oranges',contribution_pages='1,2,3'})
```
Read through listing [BSD API](https://cshift.cp.bsd.net/page/api/doc#-----------------get_contributions-------------) to know the various options for filtering data.

## CI
[![Build Status](https://secure.travis-ci.org/controlshift/blue_state_digital.png)](http://travis-ci.org/controlshift/blue_state_digital)

