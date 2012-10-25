# RestApi - RESTful client for everything

**RestApi** aims to be a generic RESTful client for ruby. The goal is to build a friendly API client that you can use right away with minimum configuration. But, if you want, you can bend the client as you wish.

## Installation

Add this line to your application's Gemfile:

    gem 'rest_api'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rest_api

## Configuration

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

Just put the above code in /config/initializers/rest_api.rb

## Usage

Every request must be made through the RestApi.request object. And the expected response must be in JSON format. Then it will be parsed to a ruby hash.

```ruby
RestApi.request.my_request_method(arguments)
```

### my_request_method

This is the name of your RESTful url. It defines the **request type** and the **resources names** that will be used in the request URL.  

The method name must start with *get_*, *post_*, *put_* or *delete_* and the resources must be separated by *underscores*. 

These are reserved words that the resources cannot use as name: 

- in  
- from 
- of

**EXAMPLES**

```ruby 
# GET to "http://www.myapiurl.com/users"
RestApi.request.get_users  

# GET to "http://www.myapiurl.com/users/cars"
RestApi.request.get_cars_from_users    

# GET to "http://www.myapiurl.com/users/cars"
RestApi.request.get_cars_users  

# POST to "http://www.myapiurl.com/cars"
RestApi.request.post_cars   

# PUT to "http://www.myapiurl.com/users/cars"
RestApi.request.put_cars_users  

# DELETE to "http://www.myapiurl.com/users"
RestApi.request.delete_users  

# DELETE to "http://www.myapiurl.com/users/houses"
RestApi.request.delete_houses_from_users  
```

### arguments


The arguments of the api resource method call has two goals:

1. Modify the url adding some value after a resource using the **:resource_params** value.
2. Modify the request HEADER (*post*, *put*) or QUERYSTRING (*get*, *delete*) using the **:request_params** value .

**:resource_params**
****

You can pass a hash in the :resource_params where, for each pair, the key is the resource name in the method called and the value is the what will be put after the resource in the URL call to the API.

**EXAMPLES**

```ruby 
# DELETE to "http://www.myapiurl.com/users/7" 
RestApi.request.delete_users(:resources_params => { :users => 7})  

# PUT to "http://www.myapiurl.com/users/7/cars/" 
RestApi.request.put_cars_in_users(:resources_params => { :users => 7})  

# PUT to "http://www.myapiurl.com/users/5/cars/18" 
RestApi.request.put_cars_in_users(:resources_params => { :cars => 18, :users => 5})   

# GET to "http://www.myapiurl.com/users/18" 
RestApi.request.get_users(:resources_params => { :users => 18})  
```

**:request_params**
****

You can pass a hash in the :request_params where, for each pair, the key is the param name and the value is the param value. Then the hash will be sent in the header if the request type is a *POST* or *PUT*. If the request type is *GET* or *DELETE* it will be parsed to a querystring and will be append to the end of the url.

**EXAMPLE**

```ruby 
# POST to "http://www.myapiurl.com/users/" with "{ :user => {:name => "name"}" in the header
RestApi.request.post_users(:request_params => { :user => {:name => "myname"}})

# GET to "http://www.myapiurl.com/users?name=myname" 
RestApi.request.get_users(:request_params => { :user => {:name => "name"}})  
```

**Using both :resource_params and :request_params**
****

Obviously you can use them together.

**EXAMPLES**

```ruby 
# GET to "http://www.myapiurl.com/users/8/cars?page=5" 
RestApi.request.get_cars_from_users(:request_params => { :page => 5}, 
                                    :resources_params => { :users => 8})

# POST to "http://www.myapiurl.com/users/8/cars" 
# with "{ :car => {:model => "ferrari"}" in the header
RestApi.request.post_cars_in_users(:request_params => { :car => {:model => "ferrari"}}, 
                                   :resources_params => { :users => 8})
```

**Short Syntax**
****
You can pass as many arguments you want. They will be considered as a **:resource_param** following the order in the URL.

**EXAMPLES**

```ruby 
# GET to "http://www.myapiurl.com/users/18" 
RestApi.request.get_users(18)

# GET to "http://www.myapiurl.com/users/18/cars" 
RestApi.request.get_cars_from_users(18)

# GET to "http://www.myapiurl.com/users/18/cars/6" 
RestApi.request.get_cars_from_users(18, 6) 

# PUT to "http://www.myapiurl.com/users/18/cars/6" 
RestApi.request.put_cars_in_users(18, 6) 
```

**IF** the last argument is a hash then it will be considered the **:request_params**.

**EXAMPLES**

```ruby 
# GET to "http://www.myapiurl.com/users/8/cars?page=5"
RestApi.request.get_cars_from_users(8, :page => 5)

# PUT to "http://www.myapiurl.com/users/18/"  
# with { :user => {:name => "myname"} } in the header
RestApi.request.put_users(18, :user => {:name => "myname"})

# PUT to "http://www.myapiurl.com/users/18/cars/6"  
# with { :car => {:model => "mercedes"} } in the header
RestApi.request.put_cars_in_users(18, 6, :car => {:model => "mercedes"})
```

If there is only one argument and it is a hash then it will be considered as the **:request_params**.

**EXAMPLES**

```ruby
# GET to "http://www.myapiurl.com/users/?page=5
RestApi.request.get_users(:page => 5)

# POST to "http://www.myapiurl.com/users/18/cars/6" 
# with {:car => {:model => "mercedes"} in the header
RestApi.request.post_cars_in_users(18, 6, :car => {:model => "mercedes"})
```

## Advanced Configuration

There are some considerations in the current implementation that you must be aware of to make RestApi work properly. Here we will show them to you and the configuration for each case.

#### RestApi.request_parser#ensure_resource_name
****

Every word separated by a "_" will be considered as resource.

So if you have a resource called *public_users* and make a request like this:

```ruby
RestApi.request.get_public_users
```

It will make a GET to:

*http://www.myapiurl.com/users/users/public*

To make things work properly you must ensure the name of the resource like this:

```ruby
RestApi.request_parser.ensure_resource_name :public_users
```

Then when you call:

```ruby
RestApi.request.get_public_users
```

It will make a GET to: 

*http://www.myapiurl.com/public_users*

And you can do something like this:

```ruby
RestApi.request.get_public_users(:resources_params => {:public_users => 2})
``` 

It will make a GET to: 

*http://www.myapiurl.com/public_users/2*

You can ensure more than one resource name at once:

```ruby
RestApi.request_parser.ensure_resource_name :my_resource1, :my_resource2, :my_resource3 ....
``` 

#### RestApi.request_parser#reset_ensure_resource_name
****

If you need you can reset the ensured resources names with:

```ruby
RestApi.request_parser.reset_ensure_resource_name
``` 

#### RestApi#map_custom_api_method#
****
Every resource name in the method call must be *unique*.

For instance, let's say you have a resource called categories. And each category:

* *belongs_to* a category
* *has_many/has_one* category

And you have a RESTful url like this: 

*http://www.myapiurl.com/categories/2/categories*

That allows you to get/post/put/delete the child categories of category 2. But if you try to do: 

```ruby
RestApi.request.get_categories_in_categories(2)
```

or

```ruby
RestApi.request.get_categories_in_categories(:resources_params => {:categories => 2})
```

It will make a GET to:

*http://www.myapiurl.com/categories/2/categories/2*

Because the resources params arguments are linked to a resource name defined in the method call.  

You can turn this aroud by defining a request method and mapping the resources like this:

```ruby
RestApi.map_custom_api_method :get, :subcategories_in_categories do |map| 
  map.subcategories = "categories"
end
```

Now when you do:

```ruby
RestApi.request.get_subcategories_in_categories(:resources_params => {:categories => 2})
```

Will make a GET to:

*http://www.myapiurl.com/categories/2/categories/*

If you don't define a map to some resource name in the method, it will be parsed to the RESTful URL as itself.

#### RestApi#add_restful_api_methods
****

Note that *map_custom_api_method* only declares one method per call. If you try: 

```ruby
RestApi.map_custom_api_method :get, :subcategories_in_categories do |map| 
  map.subcategories = "categories"
end

RestApi.request.put_subcategories_in_categories(:resources_params => {:categories => 2})
```

The custom *GET* mapping will be ignored and will be made a *PUT* request with the default map to:

*http://www.myapiurl.com/categories/2/subcategories/*

You can define a custom method for every HTTP verb **or** you can use the *add_restful_api_methods* method. This method automatically create the *GET*, *POST*, *PUT* and *DELETE*. 

**EXAMPLE**

```ruby
RestApi.add_restful_api_methods :subcategories_in_categories do |map| 
  map.subcategories = "categories"
end
```

Now you can do:

```ruby
RestApi.request.put_subcategories_in_categories(:resources_params => {:subcategories => 5, :categories => 2})
```
That a PUT will be made to:

*http://www.myapiurl.com/categories/2/categories/5*

#### RestApi#unmap_resources
****

If yout need to reset the mapped resources you can call:

```ruby
RestApi.unmap_resources
```

## TODO

Here we will put the features that will be implemented in the future.

* API autentication  
* Extend the client to accept others formats than JSON
* Create the RestApi::Model to work like an ActiveRecord model (ok. we have a long way to go)
* ...
* 
## Contact

If you have any suggestions or a bug fix feel free to create a new issue.

You can visit our page on <http://www.codus.com.br>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request