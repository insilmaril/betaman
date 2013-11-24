class Company < ActiveRecord::Base
  attr_accessible :name
  has_many :users

  def self.find_by_name(name)
    Company.where('lower(name) = ?', name.downcase ).first
  end
end
