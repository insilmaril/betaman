#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

class BetaAdmin
  def initialize
    @agent = Mechanize.new
    @agent_iw = Mechanize.new
    # Uncommment below to enable logging while extending Mailman
    #@agent.log = Logger.new $stdout
    #@agent.agent.http.debug_output = $stdout

    $options || $options = {}
  end

  def login_innerweb(user,pass)
    Blog.info "Logging into Innerweb as #{user}..."
    page = @agent_iw.get 'https://innerweb.novell.com'

    form = page.form
    page = @agent_iw.submit(form, form.buttons.first)

    form = page.form('IDPLogin')
    form.Ecom_User_ID = user
    form.Ecom_Password = pass
    page = @agent_iw.submit(form, form.buttons.first)
  end

  def login(user,pass)
    page = @agent.get 'https://login.attachmategroup.com/nidp/idff/sso?id=15&sid=0&option=credential&sid=0'
    form = page.form('IDPLogin')
    form.Ecom_User_ID = user
    form.Ecom_Password = pass
    @agent.submit(form, form.buttons.first)
  end


  def add( beta, options = {})
    email = options[:email]
    elogin = options[:elogin]
    company = options[:company]

    email_used = ""

    puts "Get search page..." if $debug
    
    url_add = 'https://www.novell.com/beta/admin/GetAddCustomer.do?id=' + beta.novell_id
    # Search for email  
    page = @agent.get url_add 

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
        page = @agent.get url_add 

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
      page = @agent.submit(form, form.button_with(:name => 'buttons.submit'))
      m = /has been successfully added/.match(page.at(".bodyCopyRed").content)

      if m
        puts "        Added #{email} - #{elogin}".green
      else
        puts "Failed to add #{email} - #{elogin}".red
        return nil
      end
    end

    return email_used
  end

  def customers(beta)
    return nil if !beta.has_novell_download?

    url_list = 'http://www.novell.com/beta/admin/GetEditCustomerInfo.do?id='

    # Search for email  
    page = @agent.get  url_list + beta.id.to_s
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

  def sync_downloads(beta)
    Blog.info "#{beta.name}: Check downloads of users"

    page_csv = @agent_iw.get "https://innerweb.novell.com/beta/GetCustomerAddressBookPrint.do?id=#{beta.novell_id}"
  
    s = page_csv.body

    #s = File.read  '/suse/uwedr/SUSE_Linux_Enterprise_Server_12__(Authorized)_.csv'

    # Fix broken encoding
    s.encode!("ISO-8859-1", "utf-8", :invalid => :replace)

    csv = CSV.parse(s)

    emails_found      = []
    users_created     = []
    companies_created = []
    downloads_added   = []
    downloads_dropped = []

    csv.drop(5).each do |r|  
      changed = false

      #Email is the mandatory field
      email = r[2]
      if !email.blank?
        # Check for duplicate emails
        if !emails_found.include? email
          emails_found << email.downcase
         
          # Find by email
          user = User.find_by_email(email)
          if !user
            # Try to find by alt_email
            user = User.find_by_alt_email(email)
            if !user
              user = User.new
              user.email = email
              users_created << user
              user.betas << beta
              user.save!
              Blog.info "  Created #{user.logname} and added to beta."
            end
          end

          # Add to beta, create participation
          if !user.betas.include? beta
            user.betas << beta
          end

        end # No duplicate email
        # else Blog.warn "  Warning: Ignoring previously found #{email}"

      end # email found
    end  # CSV

    Participation.where("beta_id = ?",beta.id).each do |p|
      if emails_found.include?(p.user.email.downcase) || 
        (!p.user.alt_email.blank? && emails_found.include?(p.user.alt_email.downcase) )
        if p.downloads_act.blank? 
          Blog.info "  Adding download flag for #{p.user.logname}"
          p.downloads_act = true
          p.save
          downloads_added << p.user
        end
      else
        if p.downloads_act.nil? 
          # Initialize download flag
          p.downloads_act = false
          p.save
        elsif p.downloads_act == true
          Blog.info "  Removing download flag for #{p.user.logname}"
          downloads_dropped << p.user
        end
      end
    end
    return {added: downloads_added, dropped: downloads_dropped }
  end
end
