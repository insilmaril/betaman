require 'spec_helper'

describe BetasController do
  render_views

  describe "for non-logged-in users" do
    it "should redirect to login page" do
      get :index
      #response.should redirect_to '/session/login'
      response.body.should have_content "Finished Betas"
    end
  end

  describe "for logged-in users" do
    before(:each) do
      #FactoryGirl.create(:beta)
      #test_login_user
      assume_login
    end

    it "gets INDEX" do
      get :index
      assert_response :success
      assert_not_nil assigns(:betas)
    end

    it "gets users" do
      beta = FactoryGirl.create(:beta)
      get :users, { id: beta }
      assert_response :success
      assert_not_nil assigns(:beta)
      assert_not_nil assigns(:users)
    end
  end
end

