# coding: utf-8

require 'spec_helper'
require 'ostruct'
require 'set'

describe "RestApi::API - url_parser" do
  let (:fake_api_url) { "http://www.fakeurl.com/" }
  before(:each) {
    RestApi.setup do |config|
      config.api_url = "http://www.fakeurl.com/"
    end
  }

  describe "ensured_resource_names" do 
    it "should return a new set if empty" do 
      RestApi.api::RequestParser.send(:ensured_resource_names).should be_empty
    end

    it "should preserve the content" do 
      RestApi.api::RequestParser.send(:ensured_resource_names) << :one
      RestApi.api::RequestParser.send(:ensured_resource_names) << :two

      RestApi.api::RequestParser.send(:ensured_resource_names).length.should be == 2
    end
  end

  describe "ensure_resource_name" do 
    it "should add the resource name to the set of ensured resources names" do 
      RestApi.api::RequestParser.ensure_resource_name :my_resource
      RestApi.api::RequestParser.send(:ensured_resource_names).include?("my_resource").should be == true
    end

    it "should accept many arguments" do 
      RestApi.api::RequestParser.ensure_resource_name :my_resource1, :my_resource2, :my_resource13
      RestApi.api::RequestParser.send(:ensured_resource_names).include?("my_resource1").should be == true
      RestApi.api::RequestParser.send(:ensured_resource_names).include?("my_resource2").should be == true
      RestApi.api::RequestParser.send(:ensured_resource_names).include?("my_resource13").should be == true
    end

    it "should  raise ArgumentError when there is no argument" do 
      lambda {
        RestApi.api::RequestParser.ensure_resource_name
      }.should raise_exception(ArgumentError)
    end
  end


  describe "reset_ensure_resource_name" do 
    it "should clear the ensured_resource_names set" do 
      RestApi.api::RequestParser.ensure_resource_name :my_resource
      RestApi.api::RequestParser.ensure_resource_name :my_resource2
      RestApi.api::RequestParser.reset_ensure_resource_name
      
      RestApi.api::RequestParser.send(:ensured_resource_names).length.should be == 0
    end
  end

  describe "get_url_from_method" do 
    it "should return the corret url with params" do 
      RestApi.api::RequestParser.send(:get_url_from_method, :get_casas_from_usuarios, {:usuarios => 3}).should be == "#{fake_api_url}usuarios/3/casas"

      RestApi.api::RequestParser.send(:get_url_from_method, :put_casas_from_usuarios, {:usuarios => 3, :casas => 5}).should be == "#{fake_api_url}usuarios/3/casas/5"

      RestApi.api::RequestParser.send(:get_url_from_method, :get_show_usuarios, {:usuarios => 3}).should be == "#{fake_api_url}usuarios/3/show"
      RestApi.api::RequestParser.send(:get_url_from_method, :delete_usuarios, {:usuarios => 2}).should be == "#{fake_api_url}usuarios/2"
    end

    it "should return the corret url  without params" do 
      RestApi.api::RequestParser.send(:get_url_from_method, :get_casas_from_usuarios).should be == "#{fake_api_url}usuarios/casas"
    end
  end

  describe "get_url_from_map" do 
    let(:array_resources_name) { ["casas", "carros", "usuarios"] }
    let(:resources_map) { 
      map = OpenStruct.new
      map.casas = "casas"
      map.carros = "onibus"
      map.usuarios = "administrador"
      map
    }

    it "should return the corret url - with params (hash 1 item)" do 
      RestApi.api::RequestParser.send(:get_url_from_map, array_resources_name, resources_map, {:casas => 4}).should be == "#{fake_api_url}casas/4/onibus/administrador"
    end

    it "should return the corret url - with params (hash 3 itens)" do 
      RestApi.api::RequestParser.send(:get_url_from_map, array_resources_name, resources_map, {:casas => 4, :carros => 5, :usuarios => 7}).should be == "#{fake_api_url}casas/4/onibus/5/administrador/7"
    end

    it "should return the corret url - with params (array 1 item)" do 
      RestApi.api::RequestParser.send(:get_url_from_map, array_resources_name, resources_map, [4]).should be == "#{fake_api_url}casas/4/onibus/administrador"
    end

    it "should return the corret url - with params (array 3 itens)" do 
      RestApi.api::RequestParser.send(:get_url_from_map, array_resources_name, resources_map, [4, 5, 7]).should be == "#{fake_api_url}casas/4/onibus/5/administrador/7"
    end

    it "should return the corret url -without params" do 
      RestApi.api::RequestParser.send(:get_url_from_map, array_resources_name, resources_map).should be == "#{fake_api_url}casas/onibus/administrador"
    end

    it "should return the corret url 2 - without params " do 
      map = OpenStruct.new
      map.test = "test"
      RestApi.api::RequestParser.send(:get_url_from_map, ["test"], map).should be == "#{fake_api_url}test"
    end
  end

  describe "get_request_type_from_method" do 
    [:put, :post, :delete, :get].each do |tipo_do_request_esperado| 
      it "should return :#{tipo_do_request_esperado} when the method name start with #{tipo_do_request_esperado}" do 
        RestApi.api::RequestParser.send(:get_request_type_from_method, "#{tipo_do_request_esperado.to_s}_resource".to_sym).should be == tipo_do_request_esperado
        RestApi.api::RequestParser.send(:get_request_type_from_method, "#{tipo_do_request_esperado.to_s}_resource".to_sym).should be == tipo_do_request_esperado
        RestApi.api::RequestParser.send(:get_request_type_from_method, "#{tipo_do_request_esperado.to_s}_resource".to_sym).should be == tipo_do_request_esperado
        RestApi.api::RequestParser.send(:get_request_type_from_method, "#{tipo_do_request_esperado.to_s}_resource".to_sym).should be == tipo_do_request_esperado
      end
    end
  end

  describe "get_url_tokens_from_method" do 
    ["resource1", "resource2", "resource3"].each do |resource|
      it "one resource - resource name: #{resource}" do
        RestApi.api::RequestParser.send(:get_url_tokens_from_method, "get_#{resource}".to_sym).should be == [resource]
        RestApi.api::RequestParser.send(:get_url_tokens_from_method, "put_#{resource}".to_sym).should be == [resource]
        RestApi.api::RequestParser.send(:get_url_tokens_from_method, "delete_#{resource}".to_sym).should be == [resource]
        RestApi.api::RequestParser.send(:get_url_tokens_from_method, "post_#{resource}".to_sym).should be == [resource]
      end

      ["subresource1", "subresource2", "subresource3"].each do |sub_resource|
        it "two sub resources" do
          RestApi.api::RequestParser.send(:get_url_tokens_from_method, "get_#{resource}_from_#{sub_resource}".to_sym).should be == [sub_resource, resource]
          RestApi.api::RequestParser.send(:get_url_tokens_from_method, "put_#{resource}_from_#{sub_resource}".to_sym).should be == [sub_resource, resource]
          RestApi.api::RequestParser.send(:get_url_tokens_from_method, "delete_#{resource}_from_#{sub_resource}".to_sym).should be == [sub_resource, resource]
          RestApi.api::RequestParser.send(:get_url_tokens_from_method, "post_#{resource}_from_#{sub_resource}".to_sym).should be == [sub_resource, resource]
        end
      end
    end

    it "should kept the ensured resources names - one resource" do 
      RestApi.api::RequestParser.stub(:ensured_resource_names).and_return(Set.new(["public_users", "some_resource"]))
      RestApi.api::RequestParser.get_url_tokens_from_method("get_public_users".to_sym).should be == ["public_users"]
    end

    it "should kept the ensured resources names - two resources" do 
      RestApi.api::RequestParser.stub(:ensured_resource_names).and_return(Set.new(["public_users", "some_resources"]))
      RestApi.api::RequestParser.get_url_tokens_from_method("get_public_users_from_some_resources_in_admins_from_system".to_sym).sort.should be == ["public_users", "some_resources", "admins", "system"].sort
    end
  end

  describe "insert_resources_params_in_tokens_array" do 
    it "should insert the resource param as string after resource name - one subresource" do 
      tokens_array = ["usuarios", "eventos"]
      RestApi.api::RequestParser.send(:insert_resources_params_in_tokens_array, tokens_array, {:usuarios => 3}).should be == ["usuarios", "3", "eventos"]
    end

    it "should insert the resource param as string after resource name - four subresources" do 
      tokens_array = ["usuarios", "eventos", "carros", "festas"]
      RestApi.api::RequestParser.send(:insert_resources_params_in_tokens_array, tokens_array, {:usuarios => 5, :carros => 234}).should be == ["usuarios", "5", "eventos", "carros", "234", "festas"]
    end

    it "should ignore if no params" do 
      tokens_array = ["usuarios", "eventos", "carros", "festas"]
      RestApi.api::RequestParser.send(:insert_resources_params_in_tokens_array, tokens_array, {}).should be == ["usuarios", "eventos", "carros", "festas"]
    end

    it "should accept params as an array - same number of resources" do 
      tokens_array = ["usuarios", "eventos", "carros", "festas"]
      RestApi.api::RequestParser.send(:insert_resources_params_in_tokens_array, tokens_array, [1,2,3,4]).should be == ["usuarios", "1", "eventos", "2", "carros", "3", "festas", "4"]
    end

    it "should accept params as an array - differnet number of resources" do 
      tokens_array = ["usuarios", "eventos", "carros", "festas"]
      RestApi.api::RequestParser.send(:insert_resources_params_in_tokens_array, tokens_array, [1,2,4]).should be == ["usuarios", "1", "eventos", "2", "carros", "4", "festas"]
    end
  end

  describe "pluralize_resource" do 
    it "should not insert s after digit" do 
      RestApi.api::RequestParser.send(:pluralize_resource, "3").should be == "3"
      RestApi.api::RequestParser.send(:pluralize_resource, "4533").should be == "4533"
      RestApi.api::RequestParser.send(:pluralize_resource, "resource3").should be == "resource3"
    end

    it "should not insert s after s" do 
      RestApi.api::RequestParser.send(:pluralize_resource, "kiss").should be == "kiss"
      RestApi.api::RequestParser.send(:pluralize_resource, "asas").should be == "asas"
      RestApi.api::RequestParser.send(:pluralize_resource, "foos").should be == "foos"
    end


    it "should not insert after anything except digit or s" do 
      RestApi.api::RequestParser.send(:pluralize_resource, "usuario").should be == "usuarios"
      RestApi.api::RequestParser.send(:pluralize_resource, "peixe").should be == "peixes"
      RestApi.api::RequestParser.send(:pluralize_resource, "carro").should be == "carros"
    end
  end
end