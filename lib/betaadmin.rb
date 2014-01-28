#!/usr/bin/env ruby

require 'colorize'
require 'csv'
require 'logger'
require 'mechanize'
require 'optparse'
require 'tempfile'
require 'yaml'

class BetaAdmin
  def initialize( user, password, id )
    @user = user
    @password = password
    @id = id

    @agent = Mechanize.new
    # Uncommment below to enable logging while extending Mailman
    #@agent.log = Logger.new $stdout
    #@agent.agent.http.debug_output = $stdout

    # URLs
    @url_login = 'https://login.attachmategroup.com/nidp/idff/sso?id=15&sid=0&option=credential&sid=0'
    @url_add = 'http://www.novell.com/beta/admin/GetAddCustomer.do?id=' 
    @url_list = 'http://www.novell.com/beta/admin/GetEditCustomerInfo.do?id='
  end

  def login
    page = @agent.get @url_login
    form = page.form('IDPLogin')
    form.Ecom_User_ID = @user
    form.Ecom_Password = @password
    @agent.submit(form, form.buttons.first)
  end


  def add(beta, email, company)
    puts "Get search page..." if $options[:debug]
    # Search for email  
    page = @agent.get @url_add + @id.to_s

    form = page.form('searchCustomerForm')

    # Criteria: 0-Username 1-Last Name 2-Email 3-Firstname
    form.field_with(:name => 'selSearchCriteria').options[2].select
    
    # Conditions: 0-Starts with  1-Ends with 2-Contains
    form.field_with(:name => 'selSearchCondition').options[0].select
    form.txtSearchInput = email

    page = @agent.submit(form, form.buttons.first)

    puts "debug: #{email},\"#{company}\"" if $options[:debug]
    
    # Process search results
    form = page.form('addCustomerForm')

    if form.radiobuttons_with(:name => 'optCustomer').count == 0 then
      puts "No customers found with email=\"#{email}\".".red
      return false
    else
      if form.radiobuttons_with(:name => 'optCustomer').count > 1 then
        puts "Multiple customers found matching email=\"#{email}\".".red
        return false
      end
    end
    puts "One customer found matching email=\"#{email}\"." if $options[:debug]

    # Search for company
    selectlist = form.field_with(:name => 'selCompany')
    company_exists = false
    co = selectlist.option_with(:value => '3547')  # matches "0-Unknown"
    if co
      co.click
    else
      puts "Error: Company not found."
      exit
    end

    form.field_with(:name => 'txtOtherCompany').value = company if !company_exists

    # Select found customer
    form.radiobuttons_with(:name => 'optCustomer').first.click

    # Finally submit
    if !$options[:dryrun]
      puts "Submitting new customer..." if $options[:debug]
      $log.info( logstring("Requesting access", beta, email, company, $options[:message]) )
      @agent.submit(form, form.button_with(:name => 'buttons.submit'))
    end
  end


  def customers
    # Search for email  
    page = @agent.get(@url_list + @id.to_s)
    #pp page

    #page = Nokogiri::HTML(open("NOVELL.html"))
    #doc = page.xpath(".//form//table//tbody//tr//td//table")

    doc = page.search(".//form//table//tr//td//table")

    customer_list = []
    doc.each do |d|
      customer = {}
      s = d.to_s
      if s.scan(/<td.*?<span.*?E-Login.*?<\/span>\s*(.*?)<br>.*?<\/td>/m).count >0 then
        customer[:company] = $1
      end
      if s.scan(/<td.*?<span.*?Email.*?<\/span>\s*<a\s+?href=\"mailto:(.*?)\".*?<\/a>.*?<\/td>/m).count >0 then
        customer[:email] = $1
      end
      if s.scan(/<td.*?<span.*?Last\sName.*?<\/span>\s*(.*?)$.*?<\/td>/m).count >0 then
        customer[:name_last] = $1
      end
      if s.scan(/<td.*?<span.*?First\sName.*?<\/span>\s*(.*?)$.*?<\/td>/m).count >0 then
        customer[:name_first] = $1
      end
      customer_list << customer if ! customer.empty?
    end
    return customer_list
  end


  def betas
    return @betatests
  end
end

def logstring (action, beta, email, company, message)
  ret = [] 
  beta = " (#{beta})" if !beta.empty?
  ret << " \"#{email}\"" if !email.empty?
  ret << " \"#{company}\"" if !company.empty?
  ret << " \"#{message}\"" if !message.empty?
  return "#{action}#{beta}: #{ret.join(",")}"
end
