class CreateExtracts < ActiveRecord::Migration[5.0]
  def change
    create_table :extracts do |t|
      t.string :title
      t.references :step, foreign_key: true
      t.string :type, :default => 'webpage'
      t.string :command

      t.timestamps
    end
  end
end
