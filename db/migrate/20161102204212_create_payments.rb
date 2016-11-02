class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.string :paymentId
      t.string :token
      t.string :PayerID
      t.boolean :executed
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :payments, :paymentId
    add_index :payments, :PayerID
  end
end
