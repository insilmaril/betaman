require 'spec_helper'

describe "Checking permissions: Admin groups" do
  it "are not accessible for regular user" do
    user = FactoryGirl.create(:user_regular)
    test_login(user)
    visit admin_groups_path
    current_path.should == root_path
  end

  it "are accessible for admin" do
    admin = FactoryGirl.create(:user_admin)
    test_login(admin)
    visit admin_groups_path
    current_path.should == admin_groups_path
  end
end
