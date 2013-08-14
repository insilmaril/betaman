require 'spec_helper'

=begin
describe "users/index" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "user@example.com",
      ),
      stub_model(User,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "user@example.com",
      )
    ])
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => "Name".to_s, :count => 4
    assert_select "tr>td", "Name"
    #assert_select "tr>td", "Email" 
  end
end

=end
