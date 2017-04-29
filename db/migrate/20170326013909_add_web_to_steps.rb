class AddWebToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :steps, :wait, :integer
    add_column :steps, :action_type, :string
    add_column :steps, :webpage, :string
  end
end
