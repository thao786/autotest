class CreatePrepTestForSuites < ActiveRecord::Migration[5.0]
  def change
    create_table :prep_test_for_suites do |t|
      t.integer :order
      t.references :test, foreign_key: true
      t.references :suite, foreign_key: true

      t.timestamps
    end
  end
end
