class Account < ActiveRecord::Base
  belongs_to :user

  validates :uid, :presence => true
end
