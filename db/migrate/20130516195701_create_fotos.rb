class CreateFotos < ActiveRecord::Migration[8.0]
  def change
    create_table :fotos do |t|
      t.string :imagem, null: false
      t.references :album, null: false, foreign_key: true
      t.string :descricao

      t.timestamps
    end
    # Só adiciona o índice se não existir
    unless index_exists?(:fotos, :album_id)
      add_index :fotos, :album_id
    end
  end
end
