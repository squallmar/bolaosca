class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :imagem
      t.string :titulo, null: false
      t.text :texto, null: false

      t.timestamps
    end
  end
end
