require 'mailmech'

class List < ActiveRecord::Base
  has_many :subscriptions, :dependent => :destroy
  has_many :users, :through => :subscriptions
  belongs_to :beta
  attr_accessible :comment, :name, :pass, :server

  def admin_link
    "#{server}/admin/#{name}"
  end

  def sync
    # Sync the internal represantation to the external "real" list
    # (which leaves the external list untouched!)
    mech = Mailmech.new(server,name,pass)

    subscribers = mech.subscribers

    users_created = []
    users_added   = []
    users_same    = []

    # Eliminate duplicates
    users.uniq!

    subscribers.each do |s|
      u = User.find_by_email(s)
      if  u
        if users.include? u
          users_same << u
        else
          users << u
          users_added << u
        end
      else
        # puts "Create user for email #{s} !"
        # FIXME add note, that user is created by list sync
        u = User.new
        u.email = s
        s =~ /(.*)@/
        u.last_name = $1 if $1
        u.save
        users_created << u
        users << u
      end
    end

    users_removed = []
    users.each do |u|
      if !subscribers.include? u.email
        users_removed << u
      end
    end
    users_removed.each do |u|
      users.delete u
    end

    return users_added, users_removed, users_created
  end

  def subscribe(user)
    mech = Mailmech.new(server,name,pass)
    mech.subscribe([user.email])
    sync
  end

  def unsubscribe(user)
    mech = Mailmech.new(server,name,pass)
    mech.delete([user.email])
    created, unsubscribed = sync
    return unsubscribed
  end
end

