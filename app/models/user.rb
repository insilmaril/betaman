class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name

  has_many :accounts
  has_many :participations
  has_many :betas, :through => :participations
  validates :email, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_admin(b)
    admin=b
    admin.save!
  end

  def set_uid(s)
    uid = s
  end

  def uids
    ar = []
    accounts.each { |a| ar << a.uid }
    ar
  end
end
