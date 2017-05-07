class AddExtractToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :steps, :extracts, :text
  end
end
