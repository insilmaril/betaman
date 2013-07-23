class Beta < ActiveRecord::Base
  attr_accessible :begin, :end, :name

  has_many :participations
  has_many :users, :through => :participations
end
