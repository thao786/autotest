class AddTitleToSuites < ActiveRecord::Migration[5.0]
  def change
    add_column :suites, :title, :string
  end
end
