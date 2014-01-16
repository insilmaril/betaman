class User < ActiveRecord::Base
  attr_accessible :email, 
    :first_name, 
    :last_name, 
    :login_name, 
    :address_attributes, 
    :note

  has_many :accounts, :dependent => :destroy
  has_many :participations, :dependent => :destroy
  has_many :betas, :through => :participations
  has_many :groups, :through => :memberships
  has_many :memberships, :dependent => :destroy
  has_and_belongs_to_many :roles
  has_many :subscriptions, :dependent => :destroy
  has_many :lists, :through => :subscriptions
  belongs_to :company
  attr_accessible :company_id
  accepts_nested_attributes_for :company
  has_one :address, :dependent => :destroy
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

  def full_name_reverse_comma
    ret = last_name
    if !first_name.blank?
      ret += ', ' + first_name
    end
    ret
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_full_name(s)
    a = s.split " "
    self.last_name = a.pop
    self.first_name = a.join " "
    self.save!
  end

  def copy(other)
    # Quick hack to merge the record itself, not the betas and lists
    self.first_name = other.first_name if !other.first_name.blank?
    self.last_name = other.last_name if !other.last_name.blank?
    self.email = other.email if !other.email.blank?
    self.login_name = other.login_name if !other.login_name.blank?
    self.note = other.note if !other.note.blank?
    if !other.address.nil?
      if self.address.nil?
        a = Address.new
        a.copy(other.address)
        self.address = a
      else
        self.address.copy other.address
      end
    end
    
    #company
    self.save!
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

  def self.find_by_email(email)
    User.where('lower(email) = ?', email.downcase ).first
  end

  def logname
    if email.nil? || email.empty? 
      return "User #{id}"
    else
      return "User #{id} (#{email})"
    end
  end

  scope :admins, lambda { User.joins(:roles).where('name = ?','Admin' ) }
  scope :employees, lambda { User.joins(:roles).where('name = ?','Employee' ) }
  scope :testers, lambda { User.joins(:roles).where('name = ?','Tester' ) }
  scope :external, lambda {User.all - User.employees }
end
