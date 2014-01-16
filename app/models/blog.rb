class Blog < ActiveRecord::Base
  def self.info( message, userid = nil)
    msg "(info)", message, userid
  end

  def self.warn( message, userid = nil)
    msg "(warn)", message, userid
  end

private
  def self.msg( type, message, userid )
    user = ""
    if userid
      email = ""
      u = User.find(userid)
      if u 
        email = "(#{u.email})"
      end
      user = "User #{userid} #{email}: "
    end
    logger.info "[BM] #{Time.now} #{type}: #{user}#{message}"
  end
end
