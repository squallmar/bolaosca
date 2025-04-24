class AddNotificacaoPontuacaoToOpcaos < ActiveRecord::Migration[8.0]
  def change
    add_column :opcaos, :notificacao_pontuacao, :boolean, default: false, null: false
  end
end
