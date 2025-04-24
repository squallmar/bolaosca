class AddStatusToBolaos < ActiveRecord::Migration[8.0]
  def change
    add_column :bolaos, :status, :string, default: 'ativo', null: false
  end
end
