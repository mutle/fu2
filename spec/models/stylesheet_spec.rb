require File.dirname(__FILE__) + '/../spec_helper'

describe Stylesheet do
  before(:each) do
    @stylesheet = Stylesheet.new
  end

  it "should be valid" do
    @stylesheet.should be_valid
  end
end
