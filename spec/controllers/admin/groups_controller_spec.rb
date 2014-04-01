require 'spec_helper'

describe Admin::GroupsController do
  describe "for non-logged-in users" do
    it "should redirect to login page" do
      get :index
      response.should redirect_to root_path
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

  describe "User management:" do
    before (:each) do
      assume_login
      @group = FactoryGirl.create(:group)
      @user_group = FactoryGirl.create(:user, email: "user1@company.com")
      @user_org   = FactoryGirl.create(:user, email: "user1@company.com")

      @user_group_id = @user_group.id
      @user_org_id   = @user_org.id

      @count_before = @group.users.count
      @group.users << @user_group
    end

    describe "before merging users" do
      it "added a user to the group" do
        @group.users.count.should == 1 + @count_before
      end
    end

    describe "after merging" do
      it "group still has same number of users" do
        @group.users.count.should == 1 + @count_before
      end

      it "has replaced the user in group with already existing one" do
        get :merge_users, :id => @group.id
        @group.reload
        user = @group.users.first
        user.id.should_not  == @user_group_id

        flash[:success].should have_content "Finished merge: Deleted 1 and updated 1 users"

      end
    end
  end
end
