class CreateSiteXPaths < ActiveRecord::Migration[6.1]
  def change
    create_table :site_xpaths do |t|
      t.integer :site_id
      t.text :xpath
      t.text :operation

      t.timestamps
    end
  end
end
