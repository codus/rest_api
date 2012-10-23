# coding: utf-8

require 'spec_helper'

describe "RestApi.api" do
  let (:fake_api_url) { "http://www.fakeurl.com/" }
  before(:each) {
    RestApi.unmap_resources
    RestApi.setup do |config|
      config.api_url = "http://www.fakeurl.com/"
    end
  }
end