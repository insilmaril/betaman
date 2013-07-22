class Beta < ActiveRecord::Base
  has_many :participations
  has_many :users, :through => :appointments

  attr_accessible :begin, :end, :name
end
