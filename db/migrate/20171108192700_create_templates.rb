class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.boolean :active
      t.text :code

      t.timestamps
    end
  end
end
