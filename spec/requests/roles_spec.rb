require 'spec_helper'

describe "Roles" do
  it "should contain admin" do
    Role.find_by_name('Admin').should_not be_nil 
  end

  it "should contain Employee" do
    Role.find_by_name('Employee').should_not be_nil 
  end

  it "should contain Tester" do
    Role.find_by_name('Tester').should_not be_nil 
  end
end
