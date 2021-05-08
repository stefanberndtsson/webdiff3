class AddColumnToSites < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :notication_tag, :text
  end
end
