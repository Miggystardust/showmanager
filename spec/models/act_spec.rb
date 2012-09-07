require 'spec_helper'
def valid_attributes
  {
    :stage_name => 'Binky',
    :length => 600,
    :short_description => 'Binky\'s act'
  }
end

describe Act do

  before (:each) do
    @act = FactoryGirl.create(:act)
  end

  it "should have valid factory" do
    FactoryGirl.build(:act).should be_valid
  end

  it "should accept whole seconds" do
    FactoryGirl.build(:act, :length => 3600).should be_valid
  end

  it "should not accept decimal lenghts" do
    FactoryGirl.build(:act, :length => 1.23).should_not be_valid
  end

  it "should not accept partial lenghts" do
    FactoryGirl.build(:act, :length => "1.2").should_not be_valid
  end

  # this test can't really work - we do accept whole numbers.
  #it "should not accept whole lenghts" do
  #  FactoryGirl.build(:act, :length => "1").should_not be_valid
  #end

  it "should not accept empty attributes" do
    FactoryGirl.build(:act, { :stage_name => nil, :length => nil, :short_description => nil } ).should_not be_valid
  end

end
