class CreateSites < ActiveRecord::Migration[6.1]
  def change
    create_table :sites do |t|
      t.text :name
      t.text :url
      t.integer :timer
      t.datetime :last_fetch
      t.text :pre_html
      t.text :pre_readable

      t.timestamps
    end
  end
end
