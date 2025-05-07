class AddSlugToRodadas < ActiveRecord::Migration[8.0]
  def change
    add_column :rodadas, :slug, :string
    add_index :rodadas, :slug, unique: true
  end
end
