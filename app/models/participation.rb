class Participation < ActiveRecord::Base
  attr_accessible :status
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

  def status_to_s
    return 'undefined' if active.nil?

    if active
      return 'active'
    else
      return 'inactive'
    end
  end
end
