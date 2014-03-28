class DiaryEntry < ActiveRecord::Base
  attr_accessible :text
  belongs_to :user
  belongs_to :beta
  belongs_to :list
  belongs_to :actor, class_name: 'User'
end
