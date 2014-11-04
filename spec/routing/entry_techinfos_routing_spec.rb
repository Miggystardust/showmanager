require "spec_helper"

describe EntryTechinfosController do
  describe "routing" do

    it "routes to #index" do
      get("/entry_techinfos").should route_to("entry_techinfos#index")
    end

    it "routes to #new" do
      get("/entry_techinfos/new").should route_to("entry_techinfos#new")
    end

    it "routes to #show" do
      get("/entry_techinfos/1").should route_to("entry_techinfos#show", :id => "1")
    end

    it "routes to #edit" do
      get("/entry_techinfos/1/edit").should route_to("entry_techinfos#edit", :id => "1")
    end

    it "routes to #create" do
      post("/entry_techinfos").should route_to("entry_techinfos#create")
    end

    it "routes to #update" do
      put("/entry_techinfos/1").should route_to("entry_techinfos#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/entry_techinfos/1").should route_to("entry_techinfos#destroy", :id => "1")
    end

  end
end
