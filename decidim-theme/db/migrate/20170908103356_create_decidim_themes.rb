class CreateDecidimThemes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_themes do |t|
      t.jsonb :name
      t.references :decidim_organization, foreign_key: true, index: true

      t.timestamps
    end
  end
end
