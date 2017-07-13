class CreateTestParams < ActiveRecord::Migration[5.0]
  def change
    create_table :test_params do |t|
      t.string :val
      t.string :label
      t.references :test, foreign_key: true

      t.timestamps
    end
  end
end
