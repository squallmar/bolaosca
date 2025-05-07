# encoding: utf-8

class Rodada < ActiveRecord::Base
  extend FriendlyId
  friendly_id :numero, use: :slugged
  belongs_to :user
  belongs_to :bolao
  has_many :jogos, dependent: :delete_all
  has_many :palpites, dependent: :delete_all
  has_many :pontuacaos, dependent: :destroy

  default_scope { order(data_inicio_apostas: :desc) }

  scope :futuras, -> {
    where("data_inicio_apostas > ? AND data_final_apostas > ?", Time.current, Time.current)
    .order(data_final_apostas: :desc)
  }

  scope :com_datas_iniciais_de_apostas_passadas, -> {
    where("data_inicio_apostas < ?", Time.current)
  }

  scope :com_apostas_abertas, -> {
    where("data_inicio_apostas < ? AND data_final_apostas > ?", Time.current, Time.current)
  }

  scope :do_bolao, ->(bolao_id) {
    where(bolao_id: bolao_id)
  }

  validates :numero, presence: true, uniqueness: { scope: :bolao_id }
  validate :validar_datas

  def validar_datas
    if data_inicio_apostas.present? && data_final_apostas.present?
      if data_final_apostas < data_inicio_apostas
        errors.add(:data_final_apostas, "não pode ser antes da data de início das apostas")
      end
    else
      errors.add(:data_inicio_apostas, "e data final são obrigatórias")
    end
  end

  def calcular_pontuacao(enviar_email = false)
    bolao.users.each do |jogador|
      jogador_palpites = jogador.palpites.da_rodada(id)
      pontos_na_rodada = 0

      unless jogador_palpites.empty?
        jogos.each_with_index do |jogo, i|
          palpite_home = jogador_palpites[i][:home].to_i
          palpite_away = jogador_palpites[i][:away].to_i
          palpite_vencedor = palpite_home <=> palpite_away
          resultado = jogo.placar_home <=> jogo.placar_away
          pontos_na_rodada += 1 if palpite_vencedor == resultado
        end
      end

      pontuacao = Pontuacao.find_or_initialize_by(user_id: jogador.id, rodada_id: id)
      pontuacao.update(pontos: pontos_na_rodada, bolao_id: bolao_id)
      NotificationMailer.informar_pontuacao_rodada(bolao, self, jogador, pontuacao).deliver if enviar_email
    end
  end

  def situacao_nao_admin
    return "Em Espera" if rodada_em_criacao?
    return "Apostas Abertas" if apostas_abertas?
    "Apostas Encerradas"
  end

  def situacao_admin
    return "Rodada em Criação - Aberta para edição" if rodada_em_criacao?
    return "Rodada com Apostas Abertas - Fechada para edição" if apostas_abertas?
    "Rodada com Apostas Encerradas - Aberta para edição*"
  end

  def rodada_em_criacao?
    !rodada_trancada?
  end

  def rodada_trancada?
    data_inicio_apostas < Time.current
  end

  def apostas_encerradas?
    data_final_apostas < Time.current
  end

  def apostas_abertas?
    !apostas_encerradas? && rodada_trancada?
  end

  def to_s
    numero.to_s
  end

  def self.rodada_atual(bolao_id)
    Rodada.do_bolao(bolao_id).com_datas_iniciais_de_apostas_passadas.first
  end

  def self.ultima_rodada_aberta(bolao_id = nil)
    if bolao_id.present?
      Rodada.do_bolao(bolao_id).com_apostas_abertas.first
    else
      Rodada.com_apostas_abertas.first
    end
  end
end
