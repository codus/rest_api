# coding: utf-8

require 'spec_helper'
require 'fakeweb'

describe "RestApi.add_custom_api_method" do
  let (:fake_api_url) { "http://www.fakeurl.com/" }
  before(:each) {
    RestApi.unmap_resources
    RestApi.setup do |config|
      config.api_url = "http://www.fakeurl.com/"
    end
    FakeWeb.allow_net_connect = false 
  }

  it "should add a method to the api module" do 
    RestApi.map_custom_api_method :put, :casa_in_usuarios
    RestApi.request.respond_to?(:put_casa_in_usuarios).should be == true
    RestApi.mapped_methods.include?(:put_casa_in_usuarios).should be == true
  end

  describe "unmap_resources" do
    it "should remove all methods" do 
      RestApi.map_custom_api_method :put, :casa_in_usuarios
      RestApi.unmap_resources
      RestApi.request.respond_to?(:put_casa_in_usuarios).should be == false
    end
  end

  context "Method add - widthout arg" do
    it "should return the url of the added method - mapped resources" do 
      RestApi.map_custom_api_method :put, :casas_in_usuarios do |map| 
        map.casas = "casinha"
        map.usuarios = "usuarionsinhos"
      end
      RestApi::RequestHandler.should_receive(:make_request).with(:put, "#{fake_api_url}usuarionsinhos/casinha", {:usuarios_id => 4}).and_return({ "status" => "ok" })
      RestApi.request.put_casas_in_usuarios(:usuarios_id => 4).should be == { "status" => "ok" }
    end

    it "should return the url of the added method - no mapped resources" do 
      RestApi.map_custom_api_method :put, :casas_in_usuarios do |map| 
        map.casas = "casinha"
        map.usuarios = "usuarionsinhos"
      end
      RestApi::RequestHandler.should_receive(:make_request).with(:put, "#{fake_api_url}usuarionsinhos/4/casinha", {:casinh_id => 8}).and_return({ "status" => "ok" })
      RestApi.request.put_casas_in_usuarios(4, :casinh_id => 8).should be == { "status" => "ok" }
    end
  end

end