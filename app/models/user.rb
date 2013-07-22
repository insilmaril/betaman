class User < ActiveRecord::Base
  has_many :accounts
  has_many :participations
  has_many :betas, :through => :participations

  attr_accessible :email, :first_name, :last_name

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_admin(b)
    admin=b
  end

  def set_uid(s)
    uid = s
  end
end
