class CreatePalpites < ActiveRecord::Migration[8.0]
  def change
    create_table :palpites do |t|
      t.references :jogo, null: false, foreign_key: true
      t.string :home, null: true
      t.string :away, null: true
      t.string :primeiro_marcador, null: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # Verifica e cria índices individuais se não existirem
    unless index_exists?(:palpites, :jogo_id)
      add_index :palpites, :jogo_id
    end

    unless index_exists?(:palpites, :user_id)
      add_index :palpites, :user_id
    end
  end
end
