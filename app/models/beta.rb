class Beta < ActiveRecord::Base
  attr_accessible :begin, :end, :name

  has_many :participations
  has_many :users, :through => :participations

  default_scope -> { order('begin DESC') }

  scope :active, where('? BETWEEN betas.begin AND betas.end', Date.current)
  scope :planned, where('betas.begin >= ?', Date.today)
  scope :finished, where('betas.end < ?', Date.today)
  scope :not_finished, where('betas.end >= ?', Date.today)
end
