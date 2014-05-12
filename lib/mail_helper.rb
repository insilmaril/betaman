module MailHelper
  def self.internal_domain?(s)
    @domains = ['suse.com','suse.de','suse.cz','novell.com','attachmate.com','netiq.com']
    @domains.each do |d|
      return true if s =~ /#{d}$/
    end
    return false
  end
end
