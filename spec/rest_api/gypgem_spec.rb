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


  it "should configure api_url - whithout slash" do 
    RestApi.setup do |config|
      config.api_url = "http://www.localhost.com:4000"
    end
    RestApi.instance_eval { api_url }.should be == "http://www.localhost.com:4000/"
  end

  it "should ensure resource name" do   
    RestApi::API::RequestParser.should_receive(:ensure_resource_name).with(:my_resource)
    RestApi.ensure_resource_name :my_resource
  end

end