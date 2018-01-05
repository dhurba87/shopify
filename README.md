# Shopify
Fetch data from shopify which are not available through API call

## Features
* Read any data from Shopify. It doesn't use shopify API.
* You can connect to multiple shops in the same application.
* Requires `domain`, `login` and `password` to fetch data.

## Examples
```
shop = Shopify.new('domain', 'username', 'password')
date_min = 1.month.ago; date_max = Time.zone.now
payout_report = shop.payout_report(date_min, date_max) # get payout reports
sales_report = shop.sales_report(date_min, date_max) # get sales report
shopify_url = shop.shopify_url # shopify url
```


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'shopify', :git => 'git://github.com/dhurba87/shopify.git'
```

And then execute:
```bash
$ bundle
```

## Contributing
Guidelines to follow:

* Fork the repo
* Create your feature branch (git checkout -b my-new-feature)
* Make sure you have some tests, and they pass!(bundle exec rake)
* Commit your changes(git commit -am 'Add some feature')
* Push to the branch( git push origin my-new-feature)
* Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
