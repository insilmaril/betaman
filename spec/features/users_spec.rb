require 'spec_helper'

describe "GET /users" do
  it "without login redirect to login" do
    visit users_path
    page.should have_content 'Login'
  end

  it "redirect regular logged-in user to root" do
    user = FactoryGirl.create(:user_regular)
    test_login(user)
    visit users_path
    current_path.should == root_path
  end

  it "lists users for employee" do
    user = FactoryGirl.create(:user_employee)
    test_login(user)
    visit users_path
    current_path.should == users_path
  end
    
  it "lists users for admin" do
    user = FactoryGirl.create(:user_admin)
    test_login(user)
    visit users_path
    current_path.should == users_path
  end
    
end

describe "Authentication" do
  subject { page }
  describe "login page" do
    before { visit '/session/login' }
    it {should have_content('OpenID') } 
  end
end
