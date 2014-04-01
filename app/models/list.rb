require 'mailmech'

class List < ActiveRecord::Base
  has_many :subscriptions, :dependent => :destroy
  has_many :users, :through => :subscriptions
  belongs_to :beta
  attr_accessible :comment, :name, :pass, :server

  def admin_link
    "#{server}/admin/#{name}"
  end

  def sync_to_intern
    # Sync the external represantation to the internal "real" list
    # (which leaves the external list untouched!)
    mech = Mailmech.new(server,name,pass)

    subscribers = mech.subscribers

    r = { 
      created: [],
      added_to_list: [],
      added_to_beta: [],
      dropped_from_list: []
    }
      
    # Eliminate duplicates
    users.uniq!

    subscribers.map{|s| s.downcase }.each do |s|
      u = User.find_by_email(s)
      if  u
        # Try to add to list
        if !users.include? u
          users << u
          r[:added_to_list] << u
        end
      else
        # Try alternate email
        u = User.find_by_alt_email(s)
        if  u
          if !users.include? u
            users << u
            r[:added_to_list] << u
          end
        else
          # puts "Create user for email #{s} !"
          u = User.new
          u.email = s
          u.note = "User created through\nList sync: #{name}"
          s =~ /(.*)@/
          u.last_name = $1 if $1
          u.save
          users << u
          r[:created] << u
          r[:added_to_list] << u
        end
      end
        
      # Try to add to beta
      if beta && beta.add_user(u)
        r[:added_to_beta] << u 
      end
    end

    users.each do |u|
      email = u.email ||= ""
      alt_email = u.alt_email ||= ""
      if !subscribers.include?(email.downcase) && !subscribers.include?(alt_email.downcase)
        r[:dropped_from_list] << u
      end

    end
    r[:dropped_from_list].each do |u|
      users.delete u
    end

    Blog.info "#{logname} sync_to_intern called:"
    Blog.info "          Created: #{r[:created].map{|u| u.logname}.join(', ')}"
    Blog.info "    Added to list: #{r[:added_to_list].map{|u| u.logname}.join(', ')}"
    Blog.info "    Added to beta: #{r[:added_to_beta].map{|u| u.logname}.join(', ')}"
    Blog.info "          Dropped: #{r[:dropped_from_list].map{|u| u.logname}.join(', ')}"

    return r
  end

  def subscribe(user)
    mech = Mailmech.new(server,name,pass)
    mech.subscribe([user.email])
  end

  def unsubscribe(user)
    mech = Mailmech.new(server,name,pass)
    mech.delete([user.email])
  end

  def logname
    if name.nil? || name.empty? 
      return "List #{id}"
    else
      return "List #{id} (#{name})"
    end
  end
end

