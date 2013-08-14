require 'spec_helper'

describe "Authentication regular user" do
  it "should provide OpenID" do
    visit "/account/login/"
    page.should have_content "OpenID"
  end

  it "should login regular user" do
    us = FactoryGirl.create(:user_regular)
    test_login_user
    #visit "/auth/open_id"
    page.should have_content 'John-User'
  end

  it "should display flash for regular user" do
    #us = FactoryGirl.create(:user_with_account)
    visit "/auth/open_id"
    visit root_path
  end
end

=begin
describe "Authentication admin" do

  it "should login admin" do
    us = FactoryGirl.create(:user_admin)
    visit "/auth/open_id"
    page.should have_content 'John-Admin'
  end
end
=end
