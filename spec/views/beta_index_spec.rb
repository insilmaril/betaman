require 'spec_helper'

describe "Beta index listing " do
  it "does not have an 'Action' column" do
    @admin = FactoryGirl.create(:user_admin)
    test_login(@admin)
    visit betas_path
    page.should_not have_content "Action"
  end
end
