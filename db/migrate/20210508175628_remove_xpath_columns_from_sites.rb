class RemoveXpathColumnsFromSites < ActiveRecord::Migration[6.1]
  def change
    remove_column :sites, :xpath_remove
    remove_column :sites, :xpath_select
  end
end
