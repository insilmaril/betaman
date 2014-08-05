class Participation < ActiveRecord::Base
  attr_accessible :beta_id, :user_id, :participation_request_id

  belongs_to :user
  belongs_to :beta
  has_one :participation_request
  
  def download_status
    if !beta.has_novell_download?
      return "n.a."
    else
      if downloads_act
        return "activated"
      else
        return "missing"
      end
    end
  end

  def active?
    return false if active.nil?
    if active
      return true
    else
      return false
    end
  end

  def toggle_active( actor = nil )
    change = ''
    if active 
      self.active = false
      change = 'deactivated'
    else
      self.active = true
      change = 'activated'
    end
    save!
    msg = "Beta participation #{change} for #{user.logname}: #{self.beta.name}"
    Blog.info msg, actor
    Diary.participation_toggled beta: self.beta, user: self.user, actor: actor, text: "Participation #{change}"
    return msg
  end

  def status_to_s
    if active?
      return 'active'
    else
      return 'inactive'
    end
  end
end
