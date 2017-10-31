class CreateTests < ActiveRecord::Migration[5.0]
  def change
    create_table :tests do |t|
      t.references :suite, foreign_key: true
      t.string :title, null: false
      t.string :name
      t.string :session_id
      t.datetime :session_expired_at
      t.datetime :code_generated_at
      t.text :description
      t.boolean :active, null: false, default: 1
      t.boolean :running, null: false, default: 0

      t.timestamps
    end
  end
end