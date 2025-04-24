class CreateBanners < ActiveRecord::Migration[8.0]
  def change
    create_table :banners do |t|
      t.string :nome, null: false
      t.integer :count_views, default: 0, null: false
      t.string :image, null: false
      t.string :link, null: false
      t.string :text
      t.string :tipo, null: false

      t.timestamps
    end

    # Adicionar índices para melhorar o desempenho
    add_index :banners, :link
    add_index :banners, :tipo
  end
end
