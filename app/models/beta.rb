require 'betaadmin'

class Beta < ActiveRecord::Base
  attr_accessible :begin, :end, :name, :alias, :novell_id, :novell_user, :novell_pass

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

  def logname
    "#{id} (#{name})"
  end

  def has_novell_download?
    return !(novell_user.blank? || novell_pass.blank? || novell_id.blank?)
  end

  def sync_downloads_to_intern
    ptotal = 0
    padded = 0
    pdropped = 0
    if has_novell_download?
      Blog.info "Beta #{name}: Sync downloads to intern:"
      admin = BetaAdmin.new( novell_user, novell_pass, novell_id)
      admin.login
      email_list = admin.customers.map{ |c| c[:email].downcase }
      ptotal = participations.count
      participations.each do |p|
        if email_list.include?(p.user.email.downcase)
          if p.downloads_act.blank? 
            Blog.info "  Adding download flag for #{p.user.logname}"
            p.downloads_act = true
            p.save
            padded += 1
          end
        else
          if p.downloads_act.nil? || p.downloads_act == true
            Blog.info "  Removing download flag for #{p.user.logname}"
            p.downloads_act = false
            p.save
            pdropped += 1
          end
        end
      end
      Blog.info "  #{participations.count} participations found."
    end
    return {added: padded, dropped: pdropped }
  end
end
