class CreateFriendlyIdSlugs < ActiveRecord::Migration[8.0]
  def change
    create_table :friendly_id_slugs do |t|
      t.string   :slug,           null: false
      t.integer  :sluggable_id,   null: false
      t.string   :sluggable_type, limit: 40, null: false
      t.datetime :created_at
    end

    add_index :friendly_id_slugs, :sluggable_id
    add_index :friendly_id_slugs, [ :slug, :sluggable_type ], unique: true
    add_index :friendly_id_slugs, :sluggable_type
  end
end
