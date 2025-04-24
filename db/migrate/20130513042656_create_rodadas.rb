class CreateRodadas < ActiveRecord::Migration[8.0]
  def change
    create_table :rodadas do |t|
      t.string :numero, null: false
      t.datetime :data_inicio_apostas, null: false
      t.datetime :data_final_apostas, null: false
      t.references :user, null: false, foreign_key: true  # Já cria index_rodadas_on_user_id
      t.references :bolao, null: false, foreign_key: true # Já cria index_rodadas_on_bolao_id

      t.timestamps
    end
    # Verifica e cria índices individuais se não existirem
    unless index_exists?(:rodadas, :user_id)
      add_index :rodadas, :user_id
    end

    unless index_exists?(:rodadas, :bolao_id)
      add_index :rodadas, :bolao_id
    end
  end
end
