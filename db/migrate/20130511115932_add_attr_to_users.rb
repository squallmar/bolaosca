class AddAttrToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :apelido, :string, null: true
    add_column :users, :sexo, :string, null: true
    add_column :users, :nome, :string, null: true
    add_column :users, :telefone, :string, null: true
    add_column :users, :avatar, :string, null: true
    add_column :users, :setor, :string, null: true

    # Adicionar índices, se necessário
    add_index :users, :apelido
    add_index :users, :telefone
  end
end
