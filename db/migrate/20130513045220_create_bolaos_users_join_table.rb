class CreateBolaosUsersJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :bolaos_users, id: false do |t|
      t.references :bolao, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end

    add_index :bolaos_users, [ :bolao_id, :user_id ], unique: true
  end
end
