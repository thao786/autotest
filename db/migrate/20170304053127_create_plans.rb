class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string :email
      t.integer :price

      t.timestamps
    end
  end
end
