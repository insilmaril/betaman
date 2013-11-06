require 'mailmech'

class List < ActiveRecord::Base
  has_many :subscriptions
  has_many :users, :through => :subscriptions
  belongs_to :beta
  attr_accessible :comment, :name, :pass, :server

  def admin_link
    "#{server}/admin/#{name}"
  end

  def sync
    mech = Mailmech.new(server,name,pass)

    users_created = []
    users_unsubscribed = []

    subscribers = mech.subscribers
    subscribers.each do |s|
      u = User.find_by_email(s)
      if  u
        if !users.include? u
          users << u
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

    users.each do |u|
      if !subscribers.include? u.email
        puts "Unsubscribe #{u.email} !" #FIXME
        users.destroy(u)
        users_unsubscribed << u  #FIXME and actually unsub user...
      end
    end

    return users_created, users_unsubscribed
  end

  def unsubscribe(user)
    mech = Mailmech.new(server,name,pass)
    mech.delete([user.email])
  end
end

