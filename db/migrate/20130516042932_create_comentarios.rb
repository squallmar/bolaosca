class CreateComentarios < ActiveRecord::Migration[8.0]
  def change
    create_table :comentarios do |t|
      t.text :texto, null: false
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # Verifica e cria índices individuais se não existirem
    unless index_exists?(:comentarios, :post_id)
      add_index :comentarios, :post_id
    end

    unless index_exists?(:comentarios, :user_id)
      add_index :comentarios, :user_id
    end
  end
end
