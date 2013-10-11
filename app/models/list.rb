require 'mailmech'

class List < ActiveRecord::Base
  has_many :subscriptions
  has_many :users, :through => :subscriptions
  attr_accessible :comment, :name, :pass, :server

  def admin_link
    "#{server}/admin/#{name}"
  end

  def refresh
    mech = Mailmech.new(server,name,pass)

    users_created = []
    users_unsubscribed = []

    puts "Init mailmech ####################"
    puts "server=#{server} name=#{name}"
    
    mech.ensure_connection
    mech.reload_subscribers
    puts "subscribers: #{mech.subscribers.count}"
    puts "count old: #{subscriptions.count}"


    #subscriptions.clear
    #puts "count clear: #{subscriptions.count}"

    puts "subscribers:"
    subscribers = mech.subscribers
    subscribers.each do |s|
      puts "  #{s}"
      u = User.find_by_email(s)
      if  u
        if !users.include? u
          users << u
        end
      else
        puts "Create user for email #{s} !"
        u = User.new
        u.email = s
        u.save
        users_created << u
        users << u
      end
    end

    users.each do |u|
      if !subscribers.include? u.email
        puts "Unsubscribe #{u.email} !"
        users_unsubscribed << u
      end
    end

    puts "Users created: #{users_created.count}"
    puts "Users unsub  : #{users_unsubscribed.count}"
    
    return users_created, users_unsubscribed
  end
end

