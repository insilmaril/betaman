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

    describe "adding users" do
      it "add user to beta has flash messages" do
        beta = FactoryGirl.create(:beta)
        user = FactoryGirl.create(:user)
        request.env["HTTP_REFERER"] = root_path
        get :add_user, {id: beta.to_param, user_id: user.to_param}
        flash[:success].should have_content "Added"
      end
    end

=begin
    it 'removes beta participation' do
      it 'flashes error message' do
        user = FactoryGirl.create(:user_with_beta) #valid_attributes
        request.env["HTTP_REFERER"] = root_path
        get :remove_beta, { id:  user.to_param, beta_id: user.betas.first.to_param} 
        flash[:error].should eql "Permission denied"
      end
    end
=end
  end
end

