class User < ActiveRecord::Base
  attr_accessible :admin, :company, :email, :email_idl, :name
end
