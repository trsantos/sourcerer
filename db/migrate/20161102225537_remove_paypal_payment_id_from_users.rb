class RemovePaypalPaymentIdFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :paypal_payment_id, :string
  end
end
