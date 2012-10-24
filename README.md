# RestApi - RESTful client for everything

RestApi aims to be a generic RESTful client for ruby. The goal is to build a friendly API client that you can use right away with minimum configuration. But, if you want, you can bend the client as you wish

## Installation

Add this line to your application's Gemfile:

    gem 'rest_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rest_api

## Usage

1. Basic configuration

* **In ruby**

```ruby
  RestApi.setup do |config|
    config.api_url = "http://www.myapiurl.com/"
  end
```

* **In Rails**

Just put the following code in /config/initializers/rest_api.rb
```ruby
  RestApi.setup do |config|
    config.api_url = "http://www.myapiurl.com/"
  end
```

2. Usage

Every request must be made calling 

```ruby
RestApi.request.*my_request_method*(*arguments*)
```

**my_request_method** 

This is the name of your RESTful url. The method name defines the request type and the *resources name* that will be used in the request URL. The method name must start with *get_*, *post_*, *put_* or *delete_* and the resources must be separated by underscores. 

There are reserved words that the resources canno't use: in, from, of.

**EXAMPLES**

* ```ruby RestApi.request.get_users `` -> **GET** to "http://www.myapiurl.com/users"

* ```ruby RestApi.request.get_cars_from_users `` -> **GET** to "http://www.myapiurl.com/users/cars"

* ```ruby RestApi.request.get_cars_users `` -> **GET** to "http://www.myapiurl.com/users/cars"

* ```ruby RestApi.request.post_cars `` -> **POST** to "http://www.myapiurl.com/cars" (ok. this is quite useless but you will see how to pass the user id)

* ```ruby RestApi.request.put_cars_users `` -> **PUT** to "http://www.myapiurl.com/users/cars" (ok. this is quite useless but you will see how to pass the user id in the URL)

* ```ruby RestApi.request.delete_users `` -> **DELETE** to "http://www.myapiurl.com/users" (ok. this is quite useless but you will see how to pass the user id in the URL)

* ```ruby RestApi.request.delete_houses_from_users `` -> **DELETE** to "http://www.myapiurl.com/users/houses" (ok. this is quite useless but you will see how to pass the user id in the URL)

**arguments** 

The arguments of the api resource method call has two functions: 

* 1. Modify the url adding some value after a resource using the :resource_params value
* 2. Modify the request HEADER (post, put) or QUERYSTRING (get, delete) using the :request_params value 

** Using the :resource_params **

You can pass a hash in the :resource_params where the key is the resource name in the method and the value is the value that should apear after it.

EXAMPLE

* ```ruby RestApi.request.put_cars_users(:resources_params => { :users => 4}) `` -> **PUT** to "http://www.myapiurl.com/users/4/cars"

* ```ruby RestApi.request.delete_users(:resources_params => { :users => 7})`` -> **DELETE** to "http://www.myapiurl.com/users/7" 

* ```ruby RestApi.request.put_cars_in_users(:resources_params => { :users => 7})`` -> **PUT** to "http://www.myapiurl.com/users/7/cars/" 

* ```ruby RestApi.request.put_cars_in_users(:resources_params => { :cars => 18})`` -> **PUT** to "http://www.myapiurl.com/users/cars/18" 


* ```ruby RestApi.request.get_users(:resources_params => { :users => 18})`` -> **GET** to "http://www.myapiurl.com/users/18" 

.... and so on...

** Using the request_params **

You can pass a hash in the :request_params where the key is the param name and the value is the param value. The the :request_params hash will be send in the header if the request type is a POST or PUT. If the request type is GET or DELETE it will be parsed in a querystring and will be append to the url.

EXAMPLE

* ```ruby RestApi.request.post_users(:request_params => { :user => {:name => "myname"}) `` -> **POST** to "http://www.myapiurl.com/users/" with "{ :user => {:name => "name"}" in the header

* ```ruby RestApi.request.get_users(:request_params => { :user => {:name => "name"})`` -> **GET** to "http://www.myapiurl.com/users?name=myname" 

.... and so on...

** MIXING everything **

Obviously you can pass both :request_params and :resource_params

EXAMPLE
* ```ruby RestApi.request.post_cars_in_users(:request_params => { :car => {:model => "ferrari"}, :resource_params => { :users => 8})
 ``` -> **POST** to "http://www.myapiurl.com/users/8/cars" with "{ :car => {:model => "ferrari"}" in the header

** SHORT SYNTAX **

You can pass as many args you want. They will be considered as a resource_param in the same order as the URL

Example

* ```ruby RestApi.request.get_users(18)``` -> **GET** to "http://www.myapiurl.com/users/18" 

* ```ruby RestApi.request.get_cars_from_users(18)``` -> **GET** to "http://www.myapiurl.com/users/18/cars" 

* ```ruby RestApi.request.get_cars_from_users(18,6)``` -> **GET** to "http://www.myapiurl.com/users/18/cars/6" 

* ```ruby RestApi.request.put_cars_in_users(18,6)``` -> **PUT** to "http://www.myapiurl.com/users/18/cars/6" 

.... and so on...

IF the last argument is a hash then it will be considered the :request_params.

EXAMPLE

* ```ruby RestApi.request.put_users(18, :user => {:name => "myname"})``` -> **PUT** to "http://www.myapiurl.com/users/18/"  with { :user => {:name => "myname"} } in the header

* ```ruby RestApi.request.put_cars_in_users(18, 6, :user => {:name => "myname"})``` -> **PUT** to "http://www.myapiurl.com/users/18/cars/6"  with { :car => {:model => "mercedes"} } in the header

If there is only one argument and it's a hash it will be the :request_params

* ```ruby RestApi.request.post_cars_in_users(:user => {:name => "myname"})``` -> **POST** to "http://www.myapiurl.com/users/18/cars/6"  with { :user => {:name => "myname"} } in the header

3. Advanced Configuration

MAPPING
UNIQUE METHOD
RESTFUL method

ENSURE RESOURCE NAME

unmap_resources
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request