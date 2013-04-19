require 'spec_helper'

describe "StaticPages" do

  let(:base_title) { "Betaman" } 

  subject { page } 

  describe "Home page" do
    before { visit root_path }
    it { should have_content('Beta Program') } 
    it { should have_selector('title', :text => "#{base_title}") }
    it { should_not have_selector('title', :text => "| Home " ) }

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
