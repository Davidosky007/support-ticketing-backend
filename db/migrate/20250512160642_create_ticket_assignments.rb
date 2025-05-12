class CreateTicketAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_assignments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :agent, foreign_key: { to_table: :users }
      t.datetime :assigned_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
