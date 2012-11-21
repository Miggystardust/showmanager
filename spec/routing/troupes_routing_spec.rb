require "spec_helper"

describe TroupesController do
  describe "routing" do

    it "routes to #index" do
      get("/troupes").should route_to("troupes#index")
    end

    it "routes to #new" do
      get("/troupes/new").should route_to("troupes#new")
    end

    it "routes to #show" do
      get("/troupes/1").should route_to("troupes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/troupes/1/edit").should route_to("troupes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/troupes").should route_to("troupes#create")
    end

    it "routes to #update" do
      put("/troupes/1").should route_to("troupes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/troupes/1").should route_to("troupes#destroy", :id => "1")
    end

  end
end
