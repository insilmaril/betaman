class Milestone < ActiveRecord::Base
  attr_accessible :comment, :date, :name

  has_many :miles, :dependent => :destroy
  has_many :betas, :through => :miles
end
