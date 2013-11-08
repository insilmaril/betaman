class User < ActiveRecord::Base
  attr_accessible :email, 
    :first_name, 
    :last_name, 
    :login_name, 
    :address_attributes, 
    :note

  has_many :accounts
  has_many :participations
  has_many :betas, :through => :participations
  has_and_belongs_to_many :roles
  has_many :subscriptions
  has_many :lists, :through => :subscriptions
  belongs_to :company
  attr_accessible :company_id
  accepts_nested_attributes_for :company
  has_one :address
  accepts_nested_attributes_for :address

  #validates :email, presence: true

  def admin?
    self.roles.each do  |r| 
      return true if r.name == 'Admin'
    end
    false
  end

  def make_admin
    admin_role = Role.find_by_name('Admin')
    if admin_role.nil?
      raise "Role 'Admin' missing in DB!"
    else
      self.roles << admin_role
    end
  end

  def employee?
    self.roles.each do  |r| 
      return true if r.name == 'Employee'
    end
    false
  end

  def make_employee
    employee_role = Role.find_by_name('Employee')
    if employee_role.nil?
      raise "Role 'Employee' missing in DB!"
    else
      self.roles << employee_role
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_uid(s)
    uid = s
  end

  def uids
    ar = []
    accounts.each { |a| ar << a.uid }
    ar
  end

  def add_account(provider, uid)
    if !self.has_account?(provider, uid)                                           
      self.accounts.build(uid: uid)         
    end                                                                            
  end

  def has_account?(provider, uid) 
    self.accounts.any? do |account|
      account.uid == uid && account.provider == provider
    end 
  end 

  def self.find_by_account(provider, uid)
    id = Account.find_by_provider_and_uid(provider, uid)

    # as a fallback, try the given url with or without a '/' at the end 
    if !id then
      if url.last == '/'    # try again without a '/' at the end
        id = Account.find_by_provider_and_uid("open_id", url[0...-1])
      else
        id = Account.find_by_provider_and_uid("open_id", "#{url}/")
      end 
    end
  end

  scope :admins, User.joins(:roles).where('name = ?','Admin' )
  scope :employees, User.joins(:roles).where('name = ?','Employee' )
  scope :testers, User.joins(:roles).where('name = ?','Tester' )
end
