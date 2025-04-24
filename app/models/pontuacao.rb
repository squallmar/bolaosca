class Pontuacao < ActiveRecord::Base
  belongs_to :rodada

  belongs_to :bolao

  belongs_to :user



  # Escopos

  scope :do_usuario, ->(user_id) { where(user_id: user_id) }

  scope :na_rodada, ->(rodada_id) { where(rodada_id: rodada_id) }

  scope :no_bolao, ->(bolao_id) { where(bolao_id: bolao_id) }

  scope :order_by_pontos_desc, -> { order(pontos: :desc) }



  # Método para calcular pontos do usuário em um bolão

  def self.do_usuario_no_bolao(usuario, bolao)
    Pontuacao.do_usuario(usuario).no_bolao(bolao).sum(:pontos)
  end
end
