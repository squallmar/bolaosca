class AddRodadaPalpites < ActiveRecord::Migration[8.0]
  def change
    add_column :palpites, :rodada_id, :integer, null: true
    add_index :palpites, :rodada_id
    add_foreign_key :palpites, :rodadas, column: :rodada_id
  end
end
