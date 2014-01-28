class Participation < ActiveRecord::Base
  attr_accessible :status
  attr_accessible :beta_id, :user_id

  belongs_to :user
  belongs_to :beta
  
  def download_status
    if beta.novell_user.blank? || beta.novell_pass.blank? || beta.novell_id.blank?
      return "n.a."
    else
      if downloads_act
        return "activated"
      else
        return "missing activation"
      end
    end
  end
end
