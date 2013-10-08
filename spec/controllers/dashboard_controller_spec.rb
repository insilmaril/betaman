require 'spec_helper'

describe DashboardController do
=begin
  it "should be visible in main menu" do
    visit "/dashboard"
    page.should have_content 'Dashboard'
    pp page
  end
=end

  describe 'for non-logged-in users' do
    it 'should redirect to login' do
      get :index                                                                 
      respond_to do |format| 
        response.should redirect_to '/session/login'   
      end
    end
  end

  describe "for logged-in users" do
    before(:each) do
      assume_login
    end

    it "gets INDEX" do
      get :index
      assert_response :success
      assert_not_nil assigns(:betas)
    end
  end

end
