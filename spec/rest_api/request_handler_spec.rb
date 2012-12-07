# coding: utf-8

require 'spec_helper'


describe "RestApi::request_hander" do
  let (:fake_api_url) { "http://www.fakeurl.com/" }
  before(:each) {
    RestApi.unmap_resources
    RestApi.setup do |config|
      config.api_url = "http://www.fakeurl.com/"
    end
  }

  describe "make_request" do 
    it "should raise an ApiConnectionException if the response is invalid when connection fails" do 
      FakeWeb.allow_net_connect = false
      lambda {
          RestApi::RequestHandler.make_request :get, "http://www.fakeurl.com.br/error"
      }.should raise_exception(RestApi::Exceptions::ApiConnectionException)
    end

    it "should raise an ParseResponseException if the response is invalid when is not a JSON response" do 
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:get, "http://www.fakeurl.com.br/json", :body => "")
      lambda {
          RestApi::RequestHandler.make_request :get, "http://www.fakeurl.com.br/json"
      }.should raise_exception(RestApi::Exceptions::ParseResponseException)
    end
    
    it "should call client get when request type is get" do 
      RestApi::RequestHandler::Client.should_receive(:get).with("http://www.fakeurl.com.br/test", {})
      RestApi::RequestHandler.make_request :get, "http://www.fakeurl.com.br/test"
    end

    it "should call client get with querystring when request type is get" do 
      RestApi::RequestHandler::Client.should_receive(:get).with("http://www.fakeurl.com.br/test", {:query => "value", :query2 => "value2"})
      RestApi::RequestHandler.make_request :get, "http://www.fakeurl.com.br/test", {:query => "value", :query2 => "value2"}
    end

    it "should call client post when request type is post" do 
      RestApi::RequestHandler::Client.should_receive(:post).with("http://www.fakeurl.com.br/test", {:param => :one})
      RestApi::RequestHandler.make_request :post, "http://www.fakeurl.com.br/test", {:param => :one}
    end

    it "should call client put when request type is put" do 
      RestApi::RequestHandler::Client.should_receive(:put).with("http://www.fakeurl.com.br/test/4", {:param => :one})
      RestApi::RequestHandler.make_request :put, "http://www.fakeurl.com.br/test/4", {:param => :one}
    end

    it "should call client delete with querystring when request type is delete" do 
      RestApi::RequestHandler::Client.should_receive(:delete).with("http://www.fakeurl.com.br/test", {:query => "value", :query2 => "value2"})
      RestApi::RequestHandler.make_request :delete, "http://www.fakeurl.com.br/test", {:query => "value", :query2 => "value2"}
    end

    it "should call client delete when request type is delete" do 
      RestApi::RequestHandler::Client.should_receive(:delete).with("http://www.fakeurl.com.br/test/5", {})
      RestApi::RequestHandler.make_request :delete, "http://www.fakeurl.com.br/test/5"
    end

    it "should call client get with api_url" do 
      RestApi.api_key_name = "key_name"
      RestApi.api_key_value = "key_value"

      RestApi::RequestHandler::Client.should_receive(:get).with("http://www.fakeurl.com.br/test", {:key_name => "key_value"})
      RestApi::RequestHandler.make_request :get, "http://www.fakeurl.com.br/test"
    end
  end
  
  describe "method_missing" do 
    context "GET" do
      context "Array parameters" do
        it "should return the request url - simple case" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:get, "#{fake_api_url}usuarios", nil).and_return({ "usuarios" => [ {"nome" => "Vinicius" } , { "nome" => "Bruno" }]})
          RestApi.request.get_usuarios.should be == { "usuarios" => [ {"nome" => "Vinicius" } , { "nome" => "Bruno" }]}
        end

        it "should return the request url - complciated case" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:get, "#{fake_api_url}usuarios/3/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})

          RestApi.request.get_casas_from_usuarios(3).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end

        it "should return the request url - complciated case" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:get, "#{fake_api_url}administradores/3/usuarios/7/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})

          RestApi.request.get_casas_from_usuarios_in_administradores(3, 7).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end
      end

      context "Hash parameters" do 
        it "should return the request url - more than one hash key" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:get, "#{fake_api_url}administradores/3/usuarios/7/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})
          RestApi.request.get_casas_from_usuarios_in_administradores(:resources_params => {:usuarios => 7, :administradores => 3}).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end


        it "should return the request url - one hash key" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:get, "#{fake_api_url}administradores/7/usuarios/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})
          RestApi.request.get_casas_from_usuarios_in_administradores(:resources_params => {:administradores => 7}).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end
      end

      context "Querystring" do 
        it "should return the request url with querystring" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:get, "#{fake_api_url}administradores/3/usuarios/7/casas", {:query => "test"}).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})
          RestApi.request.get_casas_from_usuarios_in_administradores(:resources_params => {:usuarios => 7, :administradores => 3}, :request_params => {:query => "test"}).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end
      end
    end
    context "DELETE" do
      context "Array parameters" do
        it "should return the request url - simple case" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:delete, "#{fake_api_url}usuarios", nil).and_return({ "usuarios" => [ {"nome" => "Vinicius" } , { "nome" => "Bruno" }]})
          RestApi.request.delete_usuarios.should be == { "usuarios" => [ {"nome" => "Vinicius" } , { "nome" => "Bruno" }]}
        end

        it "should return the request url - complciated case" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:delete, "#{fake_api_url}usuarios/3/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})

          RestApi.request.delete_casas_from_usuarios(3).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end

        it "should return the request url - complciated case" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:delete, "#{fake_api_url}administradores/3/usuarios/7/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})

          RestApi.request.delete_casas_from_usuarios_in_administradores(3, 7).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end
      end

      context "Hash parameters" do 
        it "should return the request url - more than one hash key" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:delete, "#{fake_api_url}administradores/3/usuarios/7/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})
          RestApi.request.delete_casas_from_usuarios_in_administradores(:resources_params => {:usuarios => 7, :administradores => 3}).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end


        it "should return the request url - one hash key" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:delete, "#{fake_api_url}administradores/7/usuarios/casas", nil).and_return({ "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]})
          RestApi.request.delete_casas_from_usuarios_in_administradores(:resources_params => {:administradores => 7}).should be == { "casas" => [ {"rua" => "rua1"}, {"rua" => "rua2"}]}
        end
      end
    end

    context "PUT" do
      context "Array parameters" do
        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:put, "#{fake_api_url}usuarios", {:usuarios => 5}).and_return({ "status" => "ok" })
          RestApi.request.put_usuarios(:request_params => {:usuarios => 5}).should be == { "status" => "ok" }
        end

        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:put, "#{fake_api_url}administradores/update", {:administradores => 5}).and_return({ "status" => "ok" })
          RestApi.request.put_update_in_administradores(:request_params => {:administradores => 5}).should be == { "status" => "ok" }
        end
      end

      context "Hash parameters" do 
        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:put, "#{fake_api_url}usuarios", {:usuarios => 5}).and_return({ "status" => "ok" })
          RestApi.request.put_usuarios(:usuarios => 5).should be == { "status" => "ok" }
        end
        
        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:put, "#{fake_api_url}usuarios/casas", {:usuarios_id => 5, :casa_id => 15}).and_return({ "status" => "ok" })
          RestApi.request.put_casas_in_usuarios(:usuarios_id => 5, :casa_id => 15).should be == { "status" => "ok" }
        end
      end
    end

    context "POST" do
      context "Array parameters" do
        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:post, "#{fake_api_url}usuarios/create", {:usuarios_nome => "teste"}).and_return({ "status" => "ok" })
          RestApi.request.post_create_usuarios(:request_params => {:usuarios_nome => "teste"}).should be == { "status" => "ok" }
        end

        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:post, "#{fake_api_url}administradores/create", {:usuarios_nome => "teste"}).and_return({ "status" => "ok" })
          RestApi.request.post_create_in_administradores(:request_params => {:usuarios_nome => "teste"}).should be == { "status" => "ok" }
        end
      end

      context "Hash parameters" do 
        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:post, "#{fake_api_url}usuarios", {:usuarios => 5}).and_return({ "status" => "ok" })
          RestApi.request.post_usuarios(:usuarios => 5).should be == { "status" => "ok" }
        end
        
        it "should return the request url" do 
          RestApi::RequestHandler.should_receive(:make_request).with(:post, "#{fake_api_url}usuarios/casas", {:usuarios_id => 5, :casa_id => 15}).and_return({ "status" => "ok" })
          RestApi.request.post_casas_in_usuarios(:usuarios_id => 5, :casa_id => 15).should be == { "status" => "ok" }
        end
      end
    end
  end
  
  describe "get_params_from_array_arguments" do 
    it "should return resources hash from a simple array" do 
      RestApi.request.get_params_from_array_arguments([2,3,4,5]).should be == {:resources_params => [2,3,4,5]}
    end

    it "should return resources hash from a simple array and request_params" do 
      RestApi.request.get_params_from_array_arguments([2,3,4,5, { :parametro1 => "true"}]).should be == {:resources_params => [2,3,4,5], :request_params =>  { :parametro1 => "true"}}
    end

    it "should return resources hash from an array with position 0 with a hash" do 
      RestApi.request.get_params_from_array_arguments([{:resources_params => [2,4,5], :request_params =>  { :parametro1 => "true"}}]).should be == {:resources_params => [2,4,5], :request_params =>  { :parametro1 => "true"}}
    end
  end
 
end