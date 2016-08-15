class UserMailer < ActionMailer::Base
  default from: "Harry's <welcome@harrys.com>"

  def signup_email(user)
    @user = user
    @twitter_message = "#Shaving is evolving. Excited for @harrys to launch."

    mail(:to => user.email, :subject => "Thanks for signing up!")
  end

  def milestone_email(user, referral)
    @user = user
    @referral = referral
    @twitter_message = "#Shaving is evolving. Excited for @harrys to launch."

    mail(:to => user.email, :subject => "You've reached a milestone!")
  end
end
