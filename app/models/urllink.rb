class Urllink < ActiveRecord::Base
  attr_accessible :beta_id, :url_id

  belongs_to :url
  belongs_to :beta
end
