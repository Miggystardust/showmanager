require 'spec_helper'

describe "EntryTechinfos" do
  describe "GET /entry_techinfo" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get entry_techinfos_path
      response.status.should be(200)
    end
  end
end
