require 'spec_helper'

describe "Beta listing of a user with a beta" do
  before(:each) do
    @admin = FactoryGirl.create(:user_admin)
    @user  = FactoryGirl.create(:user_regular)
    @beta  = FactoryGirl.create(:beta_active)
    @user.betas << @beta
    @user.save!
  end

  it "does have a beta" do
    test_login(@admin)
    visit user_betas_path(@user)
    page.should have_content "Active Beta example"
  end

  it "does not have an 'Action' column" do
    test_login(@admin)
    visit user_betas_path(@user)
    page.should_not have_content "Action"
  end
end
