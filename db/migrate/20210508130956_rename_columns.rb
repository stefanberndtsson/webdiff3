class RenameColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :sites, :pre_html, :xpath_remove
    rename_column :sites, :pre_readable, :xpath_select
    rename_column :site_versions, :html, :raw_html
  end
end
