class AddBolaoIdToPalpites < ActiveRecord::Migration[8.0]
  def change
    add_column :palpites, :bolao_id, :integer
    add_index :palpites, :bolao_id
    add_foreign_key :palpites, :bolaos

    # Para preencher dados existentes baseado nas rodadas
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE palpites
          SET bolao_id = rodadas.bolao_id
          FROM rodadas
          WHERE palpites.rodada_id = rodadas.id
        SQL
      end
    end
  end
end
