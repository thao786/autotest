class CreateDrafts < ActiveRecord::Migration[5.0]
  def change
    create_table :drafts do |t|
      t.integer :stamp, :limit => 8
      t.text :webpage
      t.string :apk
      t.string :activity
      t.string :action_type
      t.string :session_id
      t.string :typed
      t.integer :scrollTop
      t.integer :scrollLeft
      t.integer :x
      t.integer :y
      t.string :selector
      t.integer :screenwidth
      t.integer :screenheight
      t.string :tabId
      t.string :windowId

      t.timestamps
    end
  end
end



