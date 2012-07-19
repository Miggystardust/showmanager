require "spec_helper"

describe ShowItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/show_items").should route_to("show_items#index")
    end

    it "routes to #new" do
      get("/show_items/new").should route_to("show_items#new")
    end

    it "routes to #show" do
      get("/show_items/1").should route_to("show_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/show_items/1/edit").should route_to("show_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/show_items").should route_to("show_items#create")
    end

    it "routes to #update" do
      put("/show_items/1").should route_to("show_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/show_items/1").should route_to("show_items#destroy", :id => "1")
    end

  end
end
