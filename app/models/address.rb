class Address < ActiveRecord::Base
  attr_accessible :address1, :address2, :address3, :city, :country, :phone, :state, :zip
  belongs_to :user
  accepts_nested_attributes_for :user
end
