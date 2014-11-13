class Url < ActiveRecord::Base
  attr_accessible :comment, :internal, :date, :url

  has_many :urllinks, :dependent => :destroy
  has_many :betas, :through => :urllinks
end
