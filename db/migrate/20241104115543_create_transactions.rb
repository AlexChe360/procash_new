class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.string :transaction_id
      t.string :decimal
      t.string :status
      t.decimal :amount
      t.string :currency
      t.datetime :transaction_date

      t.timestamps
    end
  end
end
