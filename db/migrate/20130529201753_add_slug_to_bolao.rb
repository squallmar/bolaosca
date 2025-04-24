class AddSlugToBolao < ActiveRecord::Migration[8.0]
  def change
    add_column :bolaos, :slug, :string, null: false
    add_index :bolaos, :slug, unique: true
  end
end
