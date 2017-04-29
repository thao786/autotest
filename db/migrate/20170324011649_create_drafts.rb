class CreateDrafts < ActiveRecord::Migration[5.0]
  def change
    create_table :drafts do |t|
      t.timestamp :stamp
      t.string :webpage
      t.string :apk
      t.string :activity
      t.string :action_type
      t.string :session_id

      t.timestamps
    end
  end
end
