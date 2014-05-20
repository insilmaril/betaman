class ParticipationRequest < ActiveRecord::Base
  attr_accessible :participation_id, :user_id

  belongs_to :user
  belongs_to :participation
end
