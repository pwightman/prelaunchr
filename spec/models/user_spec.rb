require 'rails_helper'
require 'securerandom'

RSpec.describe User, type: :model do
  it 'should error when saving without email' do
    expect do
      user = User.new
      user.save!
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should error when saving with malformed email' do
    expect do
      User.create!(email: 'notanemail')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should generate a referral code on creation' do
    user = User.new(email: 'user@example.com')
    user.run_callbacks(:create)
    expect(user).to receive(:create_referral_code)
    user.save!
    expect(user.referral_code).to_not be_nil
  end

  it 'should send a welcome email on save' do
    count = Delayed::Job.count
    user = User.new(email: 'user@example.com')
    user.run_callbacks(:create)
    expect(user).to receive(:send_welcome_email)
    expect(Delayed::Job.count).to equal(count + 1)
    user.save!
  end

  it 'should queue milestone email if subscribed' do
    user = User.create!(email: 'user@example.com')
    count = Delayed::Job.count
    user.send_milestone_email User::REFERRAL_STEPS.first
    expect(Delayed::Job.count).to equal(count + 1)
    user.save!
  end

  it 'should not queue welcome email on save if not subscribed' do
    count = Delayed::Job.count
    user = User.new(email: 'user@example.com', subscribed: false)
    user.run_callbacks(:create)
    expect(user).to receive(:send_welcome_email)
    expect(Delayed::Job.count).to equal(count)
    user.save!
  end

  it 'should not queue milestone email on save if not subscribed' do
    count = Delayed::Job.count
    user = User.create!(email: 'user@example.com', subscribed: false)
    user.send_milestone_email User::REFERRAL_STEPS.first
    expect(Delayed::Job.count).to equal(count)
    user.save!
  end

end

RSpec.describe UsersHelper do
  describe 'unused_referral_code' do
    it 'should return the same referral code if there is no collision' do
      expect(User).to receive(:find_by_referral_code).and_return(nil)
      UsersHelper.unused_referral_code
    end

    it 'should return a new referral code if there is a collision' do
      expect(User).to receive(:find_by_referral_code)
        .exactly(2).times.and_return('collision', nil)
      UsersHelper.unused_referral_code
    end
  end
end
