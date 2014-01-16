class Blog < ActiveRecord::Base
  def self.info( message, user = nil)
    msg "(info)", message, user
  end

  def self.warn( message, user = nil)
    msg "(warn)", message, user
  end

private
  def self.msg( type, message, user = nil )
    username = ""
    if user
      if user.email.nil? || user.email.empty? 
        username = "User #{user.id}: "
      else
        username = "User #{user.id} (#{user.email}): "
      end
    end
    logger.info "[BM] #{Time.now} #{type}: #{username}#{message}"
  end
end
