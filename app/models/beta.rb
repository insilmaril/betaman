require 'betaadmin'

class Beta < ActiveRecord::Base
  attr_accessible :begin, :end, :name, :alias, :novell_id, :novell_user, :novell_pass, :novell_iw_user, :novell_iw_pass

  has_many :participations, :dependent => :destroy
  has_many :users, :through => :participations

  has_many :miles, :dependent => :destroy
  has_many :milestones, :through => :miles

  has_one :list

  default_scope -> { order('begin DESC') }

  scope :active, where('? BETWEEN betas.begin AND betas.end', Date.current)
  scope :planned, where('betas.begin >= ?', Date.today)
  scope :finished, where('betas.end < ?', Date.today)
  scope :not_finished, where('betas.end >= ?', Date.today)

  def add_user(user, actor = nil)
    if !self.users.include? user
      self.users << user
      Diary.added_user_to_beta user: user, beta: self, actor: actor
      return true
    end
    return false
  end

  def add_users(userlist)
    added = []
    existing = []
    userlist.each do |user|
     if add_users user
        added << user.email
      else
        existing << user.email
      end
    end
    return added, existing
  end

  def remove_user(user, actor = nil)
    if self.users.include? user
      self.users.delete  user
      Diary.removed_user_from_beta user: user, beta: self, actor: actor
      return true
    end
    return false
  end

  def logname
    "#{id} (#{name})"
  end

  def has_novell_download?
    return !(novell_user.blank? || 
             novell_pass.blank? || 
             novell_iw_user.blank? ||
             novell_iw_pass.blank? ||
             novell_id.blank?)
  end
end
