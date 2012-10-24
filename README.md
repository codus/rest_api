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

or

```ruby
  RestApi.api_url = "http://www.myapiurl.com/"
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

There are two considerations in the current implementation that you must be aware of and must configure the RestApi to work properly:

1. Consideration 1 - Every word separated by a "_" will be considered as resource name EXCEPT:
* the initial get, post, put an delete
* the words from, of, in

So if you have a resource called *public_users* and make a request like this:

```ruby
RestApi.request.get_public_users
```

It will make a GET to "http://www.myapiurl.com/users/public".

If you want you can ensure a resource name with this command:

```ruby
RestApi.request_parser.ensure_resource_name :public_users
```

Then when you call

```ruby
RestApi.request.get_public_users
```

It will make a GET to "http://www.myapiurl.com/public_users".

And you can do something like this:

```ruby
RestApi.request.get_public_users :resources_params => {:public_users => 2}
``` 

It will make a GET to "http://www.myapiurl.com/public_users/2".

You can ensure more than one resource name at once

RestApi.request_parser.ensure_resource_name :my_resource1, :my_resource2, :my_resource3 ....

If you need you can reset the ensured resources names with

```ruby
RestApi.request_parser.reset_ensure_resource_name
``` 

2. Consideration 2 - Every resource name in the method call must be *unique*. For instance, let's say you have a resource called category that 

*belongs_to a category
*has_many/has_one category

So maybe you have a RESTful url like this: http://www.myapiurl.com/categories/2/categories to get/post/put/delete the child categories of category 2. But if you try

```ruby
RestApi.request.get_categories_in_categories 2
```

or

```ruby
RestApi.request.get_categories_in_categories :resources_params => {:categories => 2}
```

It will make a GET to 

http://www.myapiurl.com/categories/2/categories/2

Because the resources params arguments are linked to a resource name defined in the method call. You can turn this aroud by manually defining a request method and mapping the resources with the following command:

```ruby
RestApi.map_custom_api_method :get, :subcategories_in_categories do |map| 
  map.subcategories = "categories"
end
```

Now when you do

```ruby
RestApi.request.get_subcategories_in_categories :resources_params => {:subcategories => 2}
```

Will make a GET to

http://www.myapiurl.com/categories/2/categories/

Note that if you don't define a map to some resource name in the method it will be parsed to a url resource as itself.

Note that you only defined for the GET method. If you make

```ruby
RestApi.request.put_subcategories_in_categories :resources_params => {:categories => 2}
```

The custom mapping will be ignored and will be made a PUT to

http://www.myapiurl.com/categories/2/subcategories/

You can define a custom method for every REST verb OR you can use the *add_restful_api_methods* method. This method automatically creathe the GET, POST, PUT and DELETE methods for a given resources method name and map. Example

```ruby
RestApi.add_restful_api_methods :subcategories_in_categories do |map| 
  map.subcategories = "categories"
end
```

Now you can do:

```ruby
RestApi.request.put_subcategories_in_categories :resources_params => {:subcategories => 5, :categories => 2}
```
That a PUT will be made to:

http://www.myapiurl.com/categories/2/categories/5

If yout need to reset the mapped resources you can call

```ruby
RestApi.unmap_resources
```

## TODO

Here we will put the features that will be implemented in the future by priority.

* API autentication  
* Extend the client to accept others formats than JSON
* Create the RestApi::Model to work like an ActiveRecord model (ok. we have a long way to go)

## Contact

If you have any suggestions or a bug fix you can create a new issue or email us.

You can visit our page on <http://www.codus.com>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request