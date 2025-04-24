class AddTimesToJogos < ActiveRecord::Migration[8.0]
  def change
    add_column :jogos, :times, :string, null: true
  end
end
