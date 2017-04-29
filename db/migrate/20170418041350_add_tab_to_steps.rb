class AddTabToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :steps, :chrome_tab, :string
  end
end
