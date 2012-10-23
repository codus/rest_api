# coding: utf-8

require 'spec_helper'
require 'rest_client'
require 'fakeweb'

describe "RestApi::RequestHandler - client" do
  before :all do
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.teste.com.br", :body => "{ \"casa\":  \"teste\", \"rua\": \"teste2\"}")
    FakeWeb.register_uri(:post, "http://www.teste.com.br/resource2", :body => "{ \"casa2\":  \"teste\", \"rua\": \"teste2\"}")
    FakeWeb.register_uri(:put, "http://www.teste.com.br/resource3", :body => "{ \"casa3\":  \"teste\", \"rua3\": \"teste2\"}")
    FakeWeb.register_uri(:delete, "http://www.teste.com.br/user/3", :body => "{ \"casa6\":  \"teste\", \"rua6\": \"teste2\"}")
  end

  describe "get" do 
    it "should call RestClient get" do 
      RestClient.should_receive(:get).with("http://www.teste.com.br")
      RestApi::RequestHandler::Client.send(:get, "http://www.teste.com.br")
    end

    it "should call parse_response" do 
      RestApi::RequestHandler::Client.should_receive(:parse_response)
      RestApi::RequestHandler::Client.send(:get, "http://www.teste.com.br/")
    end

    it "should return a parsed json hash" do 
      RestApi::RequestHandler::Client.send(:get, "http://www.teste.com.br/").should be == {"casa"=>"teste", "rua"=>"teste2"}
    end
  end

  describe "post" do 
    it "should call RestClient post" do 
      RestClient.should_receive(:post).with("http://www.teste.com.br/resource2", { :param => true })
      RestApi::RequestHandler::Client.send(:post, "http://www.teste.com.br/resource2", { :param => true })
    end

    it "should call parse_response" do 
      RestApi::RequestHandler::Client.should_receive(:parse_response)
      RestApi::RequestHandler::Client.send(:post, "http://www.teste.com.br/resource2")
    end

    it "should return a parsed json hash" do 
      RestApi::RequestHandler::Client.send(:post, "http://www.teste.com.br/resource2").should be == {"casa2"=>"teste", "rua"=>"teste2"}
    end
  end
  
  describe "put" do 
    it "should call RestClient post" do 
      RestClient.should_receive(:put).with("http://www.teste.com.br/resource3", { :param => 3 })
      RestApi::RequestHandler::Client.send(:put, "http://www.teste.com.br/resource3", { :param => 3 })
    end

    it "should call parse_response" do 
      RestApi::RequestHandler::Client.should_receive(:parse_response)
      RestApi::RequestHandler::Client.send(:put, "http://www.teste.com.br/resource3")
    end

    it "should return a parsed json hash" do 
      RestApi::RequestHandler::Client.send(:put, "http://www.teste.com.br/resource3").should be == {"casa3"=>"teste", "rua3"=>"teste2"}
    end
  end

  describe "delete" do 
    it "should call RestClient post" do 
      RestClient.should_receive(:delete).with("http://www.teste.com.br/user/3")
      RestApi::RequestHandler::Client.send(:delete, "http://www.teste.com.br/user/3")
    end

    it "should call parse_response" do 
      RestApi::RequestHandler::Client.should_receive(:parse_response)
      RestApi::RequestHandler::Client.send(:delete, "http://www.teste.com.br/user/3")
    end

    it "should return a parsed json hash" do 
      RestApi::RequestHandler::Client.send(:delete, "http://www.teste.com.br/user/3").should be == {"casa6"=>"teste", "rua6"=>"teste2"}
    end
  end
end