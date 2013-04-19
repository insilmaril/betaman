require 'spec_helper'

describe "StaticPages" do

  let(:base_title) { "Betaman" } 
  describe "Home page" do
    it "should have the content 'Beta Program'" do
      visit '/static_pages/home'
      page.should have_content('Beta Program')
    end

    it "should have the base title" do
      visit '/static_pages/home'
      page.should have_selector('title',
                                :text => "#{base_title}")
    end

    it "should not have a custom title" do
      visit '/static_pages/home'
      page.should_not have_selector('title',
                                :text => "| Home " )
    end
  end

  describe "Help page" do
    it "should have the content 'Innerweb WIKI'" do
      visit '/static_pages/help'
      page.should have_content('Innerweb WIKI')
    end

    it "should have the right title" do
      visit '/static_pages/help'
      page.should have_selector('title',
                                :text => "#{base_title} | Help")
    end
  end

end
