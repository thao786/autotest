class CreateTests < ActiveRecord::Migration[5.0]
  def change
    create_table :tests do |t|
      t.references :suite, foreign_key: true
      t.string :title
      t.string :name
      t.string :session_id
      t.datetime :session_expired_at
      t.text :description
      t.text :cachesteps
      t.boolean :active
      t.string :params

      t.timestamps
    end
  end
end