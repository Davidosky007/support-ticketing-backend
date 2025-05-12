class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :subject
      t.text :description
      t.integer :status, default: 0
      t.references :customer, foreign_key: { to_table: :users }
      t.references :agent, foreign_key: { to_table: :users }, null: true
      t.boolean :agent_commented, default: false

      t.timestamps
    end
  end
end
