class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :provider
      t.string :uid
      t.string :image
      t.string :language, :default => 'ruby'

      t.timestamps
    end
  end
end