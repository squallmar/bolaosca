class CreateJogos < ActiveRecord::Migration[8.0]
  def change
    create_table :jogos do |t|
      t.integer :placar_home
      t.integer :placar_away
      t.string :time_home, null: false
      t.string :time_away, null: false
      t.references :user, foreign_key: true
      t.references :rodada, foreign_key: true

      t.timestamps
    end
    # Verifica e cria índices individuais se não existirem
    unless index_exists?(:jogos, :user_id)
      add_index :jogos, :user_id
    end

    unless index_exists?(:jogos, :rodada_id)
      add_index :jogos, :rodada_id
    end
  end
end
