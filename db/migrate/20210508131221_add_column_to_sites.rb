class AddColumnToSites < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :notification_tag, :text
  end
end
