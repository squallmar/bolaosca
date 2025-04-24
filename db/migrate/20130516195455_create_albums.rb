class CreateAlbums < ActiveRecord::Migration[8.0]
  def change
    create_table :albums do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :capa_id
      t.string :titulo, null: false
      t.string :descricao

      t.timestamps
    end
    # Só adiciona o índice se não existir
    unless index_exists?(:albums, :user_id)
      add_index :albums, :user_id
    end
  end
end
