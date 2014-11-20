require "spec_helper"

describe EntryTechinfosController do
  describe "routing" do

    it "routes to #index" do
      get("/entry_techinfo").should route_to("entry_techinfo#index")
    end

    it "routes to #new" do
      get("/entry_techinfo/new").should route_to("entry_techinfo#new")
    end

    it "routes to #show" do
      get("/entry_techinfo/1").should route_to("entry_techinfo#show", :id => "1")
    end

    it "routes to #edit" do
      get("/entry_techinfo/1/edit").should route_to("entry_techinfo#edit", :id => "1")
    end

    it "routes to #create" do
      post("/entry_techinfo").should route_to("entry_techinfo#create")
    end

    it "routes to #update" do
      put("/entry_techinfo/1").should route_to("entry_techinfo#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/entry_techinfo/1").should route_to("entry_techinfo#destroy", :id => "1")
    end

  end
end
