class AddAbertaToRodadas < ActiveRecord::Migration[8.0]
  def change
    add_column :rodadas, :aberta, :boolean
  end
end
