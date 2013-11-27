require 'spec_helper'

describe Admin::GroupsController do
  describe "for non-logged-in users" do
    it "should redirect to login page" do
      get :index
      response.should redirect_to '/session/login'
    end
  end

  describe 'for logged-in admin' do
    before(:each) do
      assume_login
    end

    it "gets INDEX" do
      get :index
      assert_response :success
      assert_not_nil assigns(:groups)
    end

    it "assigns @current_user" do
      get :index
      assigns(:current_user).should be_kind_of(User)
    end

    describe "GET show" do
      it "assigns the requested user as @user" do
        group = FactoryGirl.create(:group) 
        get :show, { id:  group.to_param} #, valid_session
        assigns(:group).should eq(group)
      end
    end
  end
end
