class AddSlugToPost < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :slug, :string, null: false
    add_index :posts, :slug, unique: true
  end
end
