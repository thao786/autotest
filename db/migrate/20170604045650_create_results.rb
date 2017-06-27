class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.references :test, foreign_key: true
      t.references :assertion, foreign_key: true
      t.references :step, foreign_key: true
      t.string :runId
      t.string :error
      t.string :webpage

      t.timestamps
    end
  end
end
