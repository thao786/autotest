class CreateAssertions < ActiveRecord::Migration[5.0]
  def change
    create_table :assertions do |t|
      t.string :webpage
      t.boolean :active
      t.string :condition
      t.references :test, foreign_key: true

      t.timestamps
    end
  end
end
