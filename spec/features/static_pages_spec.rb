require 'spec_helper'

describe "StaticPages" do
  describe "Home page" do

    it "should have the content 'Beta Program'" do
      visit '/static_pages/home'
      page.should have_content('Beta Program')
    end
  end

  describe "Help page" do

    it "should have the content 'Innerweb WIKI'" do
      visit '/static_pages/help'
      page.should have_content('Innerweb WIKI')
    end
  end
end
