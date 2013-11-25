require 'csv'

class Group < ActiveRecord::Base
  attr_accessible :comment, :name

  has_many :users, :through => :memberships
  has_many :memberships, :dependent => :destroy

  def import(file)  
    companies_created = 0
    users_created = 0

    CSV.foreach(file.path, headers: true) do |row|  
      h = row.to_hash
      logger.info "########## #{h}"

      #Email is the mandatory field
      email = h['Email'] if h['Email']
      email = h['Email Address'] if h['Email Address']
      if email
        user = User.new
        user.email = email

        company = h['Company'] if h['Company']
        company = h['Company Name'] if h['Company Name']
        if company
          # Check if company already is there 
          c = Company.find_by_name company
          if c
            user.company = c
          else
            c = Company.create!(name: company)
            user.company = c
            companies_created += 1
          end
        end
        user.set_full_name( h['Full Name'] ) if h['Full Name']

        # Address
        a = Address.new
        a.address1 = h['Address Line 1']  || ''
        a.address2 = h['Address Line 2']  || ''
        a.address3 = h['Address Line 3']  || ''
        a.city     = h['City']  || ''
        a.state    = h['State']  || ''
        a.zip      = h['Zip Code']  || ''
        a.country  = h['Country']  || ''
        a.phone    = h['Phone Number']  || ''

        if !(a.address1 + a.address2 + a.address3 + a.city + a.state + a.zip + a.country + a.phone).empty?
          a.save!
          user.address = a
        end

        self.users << user
        self.save!
        users_created += 1
      end
    end  

    return users_created, companies_created
  end  
end
