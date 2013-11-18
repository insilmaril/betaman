class Beta < ActiveRecord::Base
  attr_accessible :begin, :end, :name

  has_many :participations, :dependent => :destroy
  has_many :users, :through => :participations
  has_one :list

  default_scope -> { order('begin DESC') }

  scope :active, where('? BETWEEN betas.begin AND betas.end', Date.current)
  scope :planned, where('betas.begin >= ?', Date.today)
  scope :finished, where('betas.end < ?', Date.today)
  scope :not_finished, where('betas.end >= ?', Date.today)

  def add_users(userlist)
    added = []
    existing = []
    userlist.each do |user|
      if !self.users.include? user
        self.users << user
        added << user.email
      else
        existing << user.email
      end
    end
    return added, existing
  end
end
