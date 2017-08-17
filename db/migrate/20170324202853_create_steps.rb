class CreateSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :steps do |t|
      t.references :test, foreign_key: true
      t.timestamp :time
      t.boolean :active
      t.string :device_type
      t.string :typed
      t.string :scrollTop
      t.string :scrollLeft
      t.string :action_type
      t.string :selector
      t.integer :wait
      t.string :webpage
      t.integer :order
      t.text :config
      t.integer :screenwidth
      t.integer :screenheight
      t.string :tabId
      t.string :windowId

      t.timestamps
    end
  end
end

