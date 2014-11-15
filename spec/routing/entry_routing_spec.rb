require "spec_helper"

describe EntryController do
  describe "routing" do

    it "routes to #index" do
      get("/entry").should route_to("entry#index")
    end

    it "routes to #new" do
      get("/entry/new").should route_to("entry#new")
    end

    it "routes to #show" do
      get("/entry/1").should route_to("entry#show", :id => "1")
    end

    it "routes to #edit" do
      get("/entry/1/edit").should route_to("entry#edit", :id => "1")
    end

    it "routes to #create" do
      post("/entry").should route_to("entry#create")
    end

    it "routes to #update" do
      put("/entry/1").should route_to("entry#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/entry/1").should route_to("entry#destroy", :id => "1")
    end

  end
end
