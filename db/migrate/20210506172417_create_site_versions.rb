class CreateSiteVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :site_versions do |t|
      t.integer :site_id
      t.text :html
      t.text :readable

      t.timestamps
    end
  end
end
