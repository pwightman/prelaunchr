class AddSubscriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed, :bool
  end
end
