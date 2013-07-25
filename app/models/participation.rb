class Participation < ActiveRecord::Base
  attr_accessible :status
  attr_accessible :beta_id, :user_id

  belongs_to :user
  belongs_to :beta
end
