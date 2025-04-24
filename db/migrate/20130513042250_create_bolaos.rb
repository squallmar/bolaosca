class CreateBolaos < ActiveRecord::Migration[8.0]
  def change
    create_table :bolaos do |t|
      t.string :titulo, null: false
      t.datetime :data_inicio, null: false
      t.datetime :data_final, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    unless index_exists?(:bolaos, :user_id)
    add_index :bolaos, :user_id
    end
  end
end
