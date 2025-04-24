class CreateOpcaos < ActiveRecord::Migration[8.0]
  def change
    create_table :opcaos do |t|
      t.boolean :notificacao_prazos, default: false, null: false
      t.boolean :notificacao_contato_geral, default: false, null: false
      t.boolean :notificacao_solicitar_cadastro, default: false, null: false
      t.boolean :notificacao_novos_boloes, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    unless index_exists?(:opcaos, :user_id)
      add_index :opcaos, :user_id
    end
  end
end
