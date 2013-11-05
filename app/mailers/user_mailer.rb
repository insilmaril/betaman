class UserMailer < ActionMailer::Base
  default from: "betaman@suse.de", reply_to: "uwedr@suse.de"

  def welcome_mail(user)
    @user = user
    mail(to: 'uwedr@suse.de', subject: 'Welcome to Betaman!')
  end

  def admin_mail(subject,body)
    @body = body
    mail to: 'uwedr@suse.de', subject: "Betaman Admin: #{subject} (#{Rails.env})"
  end
end
