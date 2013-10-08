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
    before { visit '/session/login' }
    it {should have_content('OpenID') } 
  end
end



