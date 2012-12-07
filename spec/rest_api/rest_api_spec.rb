# coding: utf-8

require 'spec_helper'

describe "RestApi" do

  it "should yield self" do 
    RestApi.setup do |config|
      config.should be == RestApi
    end
  end

  it "should configure api_url - with slash" do 
    RestApi.setup do |config|
      config.api_url = "http://www.localhost.com:4000/"
    end
    RestApi.instance_eval { api_url }.should be == "http://www.localhost.com:4000/"
  end

  it "should configure api_key_name" do 
    RestApi.setup do |config|
      config.api_key_name = "api_key_name"
    end
    RestApi.instance_eval { api_key_name }.should be == "api_key_name"
  end

  it "should configure api_key_value" do 
    RestApi.setup do |config|
      config.api_key_value = "api_key_value"
    end
    RestApi.instance_eval { api_key_value }.should be == "api_key_value"
  end

  it "should configure api_url - whithout slash" do 
    RestApi.setup do |config|
      config.api_url = "http://www.localhost.com:4000"
    end
    RestApi.instance_eval { api_url }.should be == "http://www.localhost.com:4000/"
  end

  it "should return the request parser" do   
    RestApi.request_parser.should be == RestApi::API::RequestParser
  end

end