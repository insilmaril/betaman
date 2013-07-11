class User < ActiveRecord::Base
  has_many :accounts

  attr_accessible :admin, :email, :first_name, :last_name, :uid
end
