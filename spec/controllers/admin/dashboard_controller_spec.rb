require 'spec_helper'

describe Admin::DashboardController do
  describe "for non-logged-in users" do
    it "should redirect to login page" do
      get :index
      response.should redirect_to '/session/login'
    end
  end
end
