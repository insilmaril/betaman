require 'spec_helper'

describe "Admin dashboard" do
  it "is not accessible for regular user" do
    user = FactoryGirl.create(:user_regular)
    test_login(user)
    visit admin_path
    page.should_not have_content "Admin Dashboard"
  end

  it "is accessible for admin" do
    user = FactoryGirl.create(:user_admin)
    test_login(user)
    visit admin_path
    page.should have_content "Admin Dashboard"
  end
end
