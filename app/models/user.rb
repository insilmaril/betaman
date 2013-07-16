class User < ActiveRecord::Base
  has_many :accounts

  attr_accessible :email, :first_name, :last_name, :uid

  def name
    "#{first_name} #{last_name}"
  end
end
