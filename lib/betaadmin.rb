#!/usr/bin/env ruby

require 'mechanize'

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

    $options || $options = {}
  end

  def login
    page = @agent.get @url_login
    form = page.form('IDPLogin')
    form.Ecom_User_ID = @user
    form.Ecom_Password = @password
    @agent.submit(form, form.buttons.first)
  end


  def add( options = {})
    email = options[:email]
    elogin = options[:elogin]
    company = options[:company]

    email_used = ""

    puts "Get search page..." if $debug
    # Search for email  
    page = @agent.get @url_add + @id.to_s

    form = page.form('searchCustomerForm')

    # Criteria: 0-Username 1-Last Name 2-Email 3-Firstname
    form.field_with(:name => 'selSearchCriteria').options[2].select
    
    # Conditions: 0-Starts with  1-Ends with 2-Contains
    form.field_with(:name => 'selSearchCondition').options[0].select
    form.txtSearchInput = email

    page = @agent.submit(form, form.buttons.first)

    puts "debug: #{email},\"#{company}\"" if $debug
    
    # Process search results
    form = page.form('addCustomerForm')

    if form.radiobuttons_with(:name => 'optCustomer').count == 0 then
      puts "No customers found with email=\"#{email}\".".red
      if elogin.blank?
        return nil
      else
        # Search for elogin
        page = @agent.get @url_add + @id.to_s

        form = page.form('searchCustomerForm')

        # Criteria: 0-Username 1-Last Name 2-Email 3-Firstname
        form.field_with(:name => 'selSearchCriteria').options[0].select
        
        # Conditions: 0-Starts with  1-Ends with 2-Contains
        form.field_with(:name => 'selSearchCondition').options[0].select
        form.txtSearchInput = elogin

        puts "  Trying elogin: #{elogin}"
        page = @agent.submit(form, form.buttons.first)

        # Process search results
        form = page.form('addCustomerForm')

        if form.radiobuttons_with(:name => 'optCustomer').count == 0 then
          puts "No customers found with elogin=\"#{elogin}\".".red
          return nil
        end
        if form.radiobuttons_with(:name => 'optCustomer').count > 1 then
          puts "Multiple customers found matching elogin=\"#{elogin}\".".red
          return nil
        end
      end
    else
      if form.radiobuttons_with(:name => 'optCustomer').count > 1 then
        puts "Multiple customers found matching email=\"#{email}\".".red
        return nil
      end
    end
    puts "One customer found" if $debug

    page.links.each do |l|
      if !l.text.blank?
        m = /(\S*@\S*)/.match(l.text)
        email_used = m[1] if m[1] 
      end
    end

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

    #form.field_with(:name => 'txtOtherCompany').value = company if !company_exists

    # Select found customer
    form.radiobuttons_with(:name => 'optCustomer').first.click

    # Finally submit
    if !$options[:dryrun]
      puts "Submitting new customer..." if $debug
      #$log.info( logstring("Requesting access", email, company, $options[:message]) )
      @agent.submit(form, form.button_with(:name => 'buttons.submit'))
    end

    return email_used
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

def logstring (action, email, company, message)
  ret = [] 
  ret << " \"#{email}\"" if !email.empty?
  ret << " \"#{company}\"" if !company.empty?
  ret << " \"#{message}\"" if !message.blank?
  return "#{action}: #{ret.join(",")}"
end
