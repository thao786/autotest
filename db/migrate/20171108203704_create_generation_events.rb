class CreateGenerationEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :generation_events do |t|
      t.references :test, foreign_key: true
      t.references :template, foreign_key: true
      t.datetime :generated_at

      t.timestamps
    end
  end
end
