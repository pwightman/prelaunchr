require 'rails_helper'
require 'securerandom'

describe "users", type: :request do
  describe 'campaign ended' do
    before do
      allow(Rails.application.config).to receive(:ended) { true }
    end

    it 'should display campaign ended message when campaign has ended' do
      get '/'
      expect(response).to render_template(:partial => "_campaign_ended")
    end

    it 'should unsubscribe user' do
      user = User.create!(email: "#{SecureRandom.uuid}@#{SecureRandom.uuid}.com")
      expect(user.subscribed).to equal(true)

      get "/unsubscribe/#{user.unique_id}"

      user.reload
      expect(user.subscribed).to equal(false)
    end

  end
end