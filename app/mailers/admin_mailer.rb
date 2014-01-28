class AdminMailer < ActionMailer::Base
  default from: "betaman@betaman.suse.de"

  def welcome_email(user)
    @user = user
    mail(to: 'uwedr@suse.de', subject: 'Welcome to Betaman!')
  end
end