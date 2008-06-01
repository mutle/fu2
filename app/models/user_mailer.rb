class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://YOURSITE/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end
  
  def invite(invite)
    @recipients  = "#{invite.email}"
    @from        = default_email
    @subject     = "[FUCKUP-Wiki] Invitation"
    @sent_on     = Time.now
    
    @body[:user] = invite.name
    @body[:invite] = invite.activation_code
  end
  
  protected
    
    def default_email
      "fuwki.temp@gmail.com"
    end
    
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = default_email
      @subject     = "[FUCKUP-Wiki] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
