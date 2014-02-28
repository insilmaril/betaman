require 'spec_helper'

describe "Authentication " do
  it "should provide Novell" do
    visit "/session/login/"
    page.find(:css, "a[href$='auth/novell']")
  end

  it "should provide OpenID" do
    visit "/session/login/"
    page.find(:css, "a[href$='auth/open_id']")
  end

  it "should provide Google" do
    visit "/session/login/"
    page.find(:css, "a[href$='auth/google']")
  end

  it "should login regular user" do
    user = FactoryGirl.create(:user_regular)
    test_login(user)
    page.should have_content 'John-User'
  end

  it "should display flash for regular user" do
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
