class AddFotoIdToComentarios < ActiveRecord::Migration[8.0]
  def change
    add_column :comentarios, :foto_id, :integer, null: true
    add_index :comentarios, :foto_id
    add_foreign_key :comentarios, :fotos, column: :foto_id
  end
end
