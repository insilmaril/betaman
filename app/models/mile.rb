class Mile < ActiveRecord::Base
  attr_accessible :beta_id, :milestone_id

  belongs_to :milestone
  belongs_to :beta
end
