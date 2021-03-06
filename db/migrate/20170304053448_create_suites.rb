class CreateSuites < ActiveRecord::Migration[5.0]
  def change
    create_table :suites do |t|
      t.string :name
      t.text :description
      t.string :title, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end