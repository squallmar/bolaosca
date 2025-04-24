class CreatePontuacaos < ActiveRecord::Migration[8.0]
  def change
    create_table :pontuacaos do |t|
      t.references :rodada, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :bolao, null: false, foreign_key: true
      t.integer :pontos, default: 0

      t.timestamps
    end
    # Verifica e cria índices individuais se não existirem
    unless index_exists?(:pontuacaos, :bolao_id)
      add_index :pontuacaos, :bolao_id
    end

    unless index_exists?(:pontuacaos, :rodada_id)
      add_index :pontuacaos, :rodada_id
    end
    # Verifica e cria índices individuais se não existirem
    unless index_exists?(:pontuacaos, :user_id)
      add_index :pontuacaos, :user_id
    end
  end
end
