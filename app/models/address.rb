class Address < ActiveRecord::Base
  attr_accessible :address1, :address2, :address3, :city, :country, :phone, :state, :zip
  belongs_to :user
  accepts_nested_attributes_for :user

  def copy(other)
    self.address1 = other.address1 if !other.address1.blank?
    self.address2 = other.address2 if !other.address2.blank?
    self.address3 = other.address3 if !other.address3.blank?
    self.city     = other.city if !other.city.blank?
    self.state    = other.state if !other.state.blank?
    self.zip      = other.zip if !other.zip.blank?
    self.country  = other.country if !other.country.blank?
    self.phone    = other.phone if !other.phone.blank?
    self.save!
  end

  def ==(other)
    self.attributes.except('id','created_at','updated_at','user_id') ==
      other.attributes.except('id','created_at','updated_at','user_id') 
  end
end
