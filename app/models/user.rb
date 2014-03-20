class User < ActiveRecord::Base
  attr_accessible :email, :alt_email,
    :first_name, 
    :last_name, 
    :title,
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
    has_role?('Admin')
  end

  def make_admin
    add_role('Admin')
  end

  def drop_admin
    drop_role('Admin')
  end

  def employee?
    has_role?('Employee')
  end

  def make_employee
    add_role('Employee')
  end

  def drop_employee
    drop_role('Employee')
  end

  def full_name_reverse_comma
    a = []
    a << title if !title.blank?
    if !last_name.blank?
      if !first_name.blank?
        a << last_name + ','
      else
        a << last_name
      end
    end
    a << first_name if !first_name.blank?
    if a.count == 0
      return 'n.a.' 
    else
      return a.join(' ')
    end
  end

  def full_name
    a = []
    a << title if !title.blank?
    a << first_name if !first_name.blank?
    a << last_name if !last_name.blank?
    if a.count == 0
      return 'n.a.' 
    else
      return a.join(' ')
    end
  end

  def set_full_name(s)
    a = s.split " "
    last = a.pop
    first = a.join " "
    if last != self.last_name || first != self.first_name
      self.last_name = last
      self.first_name = first
      self.save!
      return true
    else
      return false
    end
  end

  def copy_contact_info(other)
    # Quick hack to merge the record itself, not the betas and lists
    self.first_name = other.first_name if !other.first_name.blank?
    self.last_name = other.last_name if !other.last_name.blank?
    self.email = other.email if !other.email.blank?
    self.login_name = other.login_name if !other.login_name.blank?
    self.note = other.note if !other.note.blank?
    if !other.address.nil?
      a = Address.new
      a.copy other.address
      a.save
      self.address = a
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

  def self.find_by_alt_email(email)
    User.where('lower(alt_email) = ?', email.downcase ).first
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

private

  def has_role?(name)
    self.roles.each do  |r| 
      return true if r.name == name
    end
    false
  end

  def add_role(name)
    role = Role.find_by_name name
    if role.nil?
      raise "Role #{name} missing in DB!"
    else
      self.roles << role
    end
  end

  def drop_role(name)
    role = Role.find_by_name name
    if role.nil?
      raise "Role #{name} missing in DB!"
    else
      r = self.roles.find(role)
      if r
        self.roles.delete r
      end
    end
  end
end
