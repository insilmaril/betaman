require 'spec_helper'

describe "Users" do
  describe "GET /users" do
    it "Redirect without login" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get users_path
      response.status.should be(302)
    end
  end
end

=begin
describe "profile page" do
  let(:user) { FactoryGirl.create(:user) }
  before { visit user_path(user) }

  it { should have_content(user.first_name) }
end
=end


describe "Authentication" do
  subject { page }
  describe "login page" do
    before { visit '/account/login' }
    it {should have_content('OpenID') } 
  end
end

