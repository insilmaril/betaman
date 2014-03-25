class Diary
  def self.logged_in user
    write "logged in", :user => user, :event => 'user_login'
  end

  def self.logged_out user
    write "logged out", :user => user, :event => 'user_logout'
  end

  def self.write text, args = {}
    d = DiaryEntry.new
    d.text    = text
    d.event   = args[:event]
    d.user_id = args[:user].try(:id)
    d.save
  end
end
