class Milestone < ActiveRecord::Base
  attr_accessible :comment, :comment_internal, :date, :name, :url

  has_many :miles, :dependent => :destroy
  has_many :betas, :through => :miles
end
