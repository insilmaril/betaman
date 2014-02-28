class Participation < ActiveRecord::Base
  attr_accessible :status
  attr_accessible :beta_id, :user_id

  belongs_to :user
  belongs_to :beta
  
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

  def status_to_s
    if active.nil?
      return 'undefined'
    elsif active
      return 'active'
    end
    return 'inactive'
  end
end
