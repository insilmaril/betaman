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

  def status_to_s
    if active?
      return 'active'
    else
      return 'inactive'
    end
  end
end
