class Diary
  # Do not change the event strings below
  # They might be replaced later by integers as unique identifiers
  #

  def self.logged_in user
    write 'logged in', user: user, event: 'logged_in'
  end

  def self.logged_out user
    write 'logged out', user: user, event: 'logged_out'
  end

  def self.joined_beta param = {}
    write 'joined beta', param.merge({event: 'joined_beta'})
  end

  def self.left_beta param = {}
    write 'left beta', param.merge({event: 'left_beta'})
  end

  def self.added_user_to_beta param = {} 
    write 'Added to beta', param.merge({event: 'added_user_to_beta'})
  end

  def self.removed_user_from_beta param = {}
    write 'Removed from beta', param.merge({event: 'removed_user_from_beta'})
  end

  def self.subscribed_user_to_list param = {}
    write "User subscribed to list", param.merge({event: 'subscribed_user_to_list'})
  end

  def self.unsubscribed_user_from_list param = {}
    write "User unsubscribed from list", param.merge({event: 'unsubscribed_user_from_list'})
  end

  def self.updated_user param = {}
    write "User updated", param.merge({event: 'user_updated'})
  end

  def self.got_employee_role param = {} 
    write "got role employee", param.merge({event: 'got_employee_role'})
  end

  def self.dropped_employee_role param = {}
    write "dropped employee role", param.merge({event: 'dropped_employee_role'})
  end

  def self.user_created param = {}
    write "Created user", param.merge({event: 'user_created'})
  end

  def self.user_deleted param = {}
    # Special case: Because user is deleted soon,
    # write to actors diary instead
    username = param[:user].logname
    param[:user] = param[:actor]
    write "Deleted #{username}", param.merge({event: 'user_deleted'})
  end

  def self.company_changed param = {}
    write "Company changed", param.merge({event: 'company_changed'})
  end

  def self.write text, param = {}
    d = DiaryEntry.new
    d.text    = param[:text] || text
    d.event   = param[:event]
    d.user_id = param[:user].try(:id)
    d.beta_id = param[:beta].try(:id)
    d.actor_id = param[:actor].try(:id)
    d.list_id = param[:list].try(:id)
    d.save
  end
end
