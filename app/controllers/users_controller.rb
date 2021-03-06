class UsersController < ApplicationController
  before_filter :skip_first_page, only: :new
  before_filter :handle_ip, only: :create

  def new
    @bodyId = 'home'
    @is_mobile = mobile_device?

    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    ref_code = cookies[:h_ref]
    email = params[:user][:email]
    @user = User.new(email: email)
    referrer =  if ref_code then User.find_by_referral_code(ref_code) else nil end
    @user.referrer = referrer

    if @user.save

      if referrer
        count = referrer.referrals.count
        milestone = User::REFERRAL_STEPS.find { |s| s['count'] == count }
        if milestone
          referrer.send_milestone_email(milestone)
        end
      end

      cookies[:h_email] = { value: @user.email }
      redirect_to '/refer-a-friend'
    else
      logger.info("Error saving user with email, #{email}")
      redirect_to root_path, alert: 'Something went wrong!'
    end
  end

  def refer
    @bodyId = 'refer'
    @is_mobile = mobile_device?

    @user = User.find_by_email(cookies[:h_email])

    respond_to do |format|
      if @user.nil?
        format.html { redirect_to root_path, alert: 'Something went wrong!' }
      else
        format.html # refer.html.erb
      end
    end
  end

  def unsubscribe
    id = params[:id]

    user = User.find_by(unique_id: id)
    if user
      user.subscribed = false
      user.save
      redirect_to "/", flash: { success: "Successfully unsubscribed." }
    else
      redirect_to "/"
    end
  end

  def policy
  end

  def rules
  end

  def redirect
    redirect_to root_path, status: 404
  end

  # TODO: Remove before going to production
  def create_bogus_user
    User.create({ email: "#{SecureRandom.uuid}@#{SecureRandom.uuid}.com" })
    render plain: "OK"
  end

  private

  def skip_first_page
    return if Rails.application.config.ended

    email = cookies[:h_email]
    if email #&& User.find_by_email(email)
      flash.keep
      redirect_to '/refer-a-friend'
    else
      cookies.delete :h_email
    end
  end

  def handle_ip
    # Prevent someone from gaming the site by referring themselves.
    # Presumably, users are doing this from the same device so block
    # their ip after their ip appears three times in the database.

    address = request.env['HTTP_X_FORWARDED_FOR']
    return if address.nil?

    current_ip = IpAddress.find_by_address(address)
    if current_ip.nil?
      current_ip = IpAddress.create(address: address, count: 1)
    elsif current_ip.count > 2
#       logger.info('IP address has already appeared three times in our records. Redirecting user back to landing page.')
#       return redirect_to root_path
    else
      current_ip.count += 1
      current_ip.save
    end
  end
end
