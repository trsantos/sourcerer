class AddPaypalPaymentIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :paypal_payment_id, :string
  end
end
