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

  def self.joined_beta user, beta
    write 'joined beta', user: user, event: 'joined_beta', beta: beta
  end

  def self.left_beta user, beta
    write 'left beta', user: user, event: 'left_beta', beta: beta
  end

  def self.added_user_to_beta user, beta, actor
    write "User #{user.id} added to beta #{beta.id} by actor #{actor.id}", user: user, event: 'added_user_to_beta', beta: beta, actor: actor
  end

  def self.removed_user_from_beta user, beta, actor
    write "User #{user.id} removed from beta #{beta.id} by actor #{actor.id}", user: user, event: 'removed_user_from_beta', beta: beta, actor: actor
  end

  def self.subscribed_user_to_list user, list, actor
    write "User #{user.id} subscribed to list #{list.id} by actor #{actor.id}", user: user, event: 'subscribe_user_to_list', list: list, actor: actor
  end

  def self.unsubscribed_user_from_list user, list, actor
    write "User #{user.id} unsubscribed from list #{list.id} by actor #{actor.id}", user: user, event: 'unsubscribe_user_from_list', list: list, actor: actor
  end

  def self.got_employee_role user, actor
    write "User #{user.id} got employee role by actor #{actor.id}", user: user, event: 'got_employee_role', actor: actor
  end

  def self.dropped_employee_role user, actor
    write "User #{user.id} dropped employee role by actor #{actor.id}", user: user, event: 'dropped_employee_role', actor: actor
  end


  def self.user_deleted user, actor
    write "User #{user.id} deleted by actor #{actor.id}", user: user, event: 'user_deleted', actor: actor
  end

  def self.write text, args = {}
    d = DiaryEntry.new
    d.text    = text
    d.event   = args[:event]
    d.user_id = args[:user].try(:id)
    d.beta_id = args[:beta].try(:id)
    d.actor_id = args[:actor].try(:id)
    d.save
  end
end
