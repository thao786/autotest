class CreatePrepTests < ActiveRecord::Migration[5.0]
  def change
    create_table :prep_tests do |t|
      t.integer :order
      t.references :test, foreign_key: true
      t.references :step, foreign_key: true
      t.references :suite, foreign_key: true

      t.timestamps
    end
  end
end
