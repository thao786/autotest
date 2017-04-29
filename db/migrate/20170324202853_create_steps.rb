class CreateSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|
      t.references :test
      t.timestamp :time
      t.boolean :active
      t.string :device_type
      t.string :typed
      t.integer :scrollTop
      t.integer :scrollLeft

      t.timestamps
    end
  end
end
