require 'users_helper'

class User < ActiveRecord::Base
  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id'
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'

  validates :email, presence: true, uniqueness: true, format: {
    with: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i,
    message: 'Invalid email format.'
  }
  validates :referral_code, uniqueness: true

  before_create :create_referral_code
  before_create :initialize_attributes
  after_create :send_welcome_email

  REFERRAL_STEPS = [
    {
      'count' => 5,
      'html' => 'Probiotic Instant Resurfacing Pads Travel Pack',
      'class' => 'two',
      'image' =>  ActionController::Base.helpers.asset_path(
        'glowbiotics/resurfacing-pads-pack.jpg')
    },
    {
      'count' => 15,
      'html' => 'Probiotic HydraGlow Cream Oil',
      'class' => 'three',
      'image' => ActionController::Base.helpers.asset_path(
        'glowbiotics/hydraglow-oil.jpg')
    },
    {
      'count' => 30,
      'html' => 'Anti-Wrinkle Illuminating Eye Cream',
      'class' => 'four',
      'image' => ActionController::Base.helpers.asset_path(
        'glowbiotics/anti-wrinkle-eye-cream.jpg')
    },
    {
      'count' => 55,
      'html' => 'Retinol Anti-Aging + Brightening Treatment',
      'class' => 'five',
      'image' => ActionController::Base.helpers.asset_path(
        'glowbiotics/retinol.jpg')
    }
  ]

  def send_milstone_email milestone
    if subscribed
      UserMailer.delay.milestone_email(self, milestone)
    end
  end

  private

  def initialize_attributes
    self.subscribed ||= true
  end

  def create_referral_code
    self.referral_code = UsersHelper.unused_referral_code
    self.unique_id = UsersHelper.unused_unique_id
  end

  def send_welcome_email
    if subscribed
      UserMailer.delay.signup_email(self)
    end
  end
end
