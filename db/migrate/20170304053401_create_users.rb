class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :provider
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end