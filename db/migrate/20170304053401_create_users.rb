class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
