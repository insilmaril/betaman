class Subscription < ActiveRecord::Base
  attr_accessible :list_id, :user_id

  belongs_to :user
  belongs_to :list
end
