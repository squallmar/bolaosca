class Palpite < ApplicationRecord
  # Associações
  belongs_to :jogo
  belongs_to :rodada
  belongs_to :user
  belongs_to :bolao

  # Validações
  validates :user_id, uniqueness: { scope: [ :jogo_id, :bolao_id ] }
  validates :home, :away, presence: true
  validates :home, inclusion: { in: [ "0", "1" ] }
  validates :away, inclusion: { in: [ "0", "1", "-1" ] }
  validate :valid_result_combination
  validate :limit_bet_types

  # Scopes
  scope :do_usuario, ->(user_id) { where(user_id: user_id) }
  scope :do_jogo, ->(jogo_id) { where(jogo_id: jogo_id) }
  scope :da_rodada, ->(rodada_id) { where(rodada_id: rodada_id) }
  scope :ordenados, -> { includes(:jogo).order("jogos.data ASC") }

  # Constantes para tipos de apostas
  HOME_WIN = "1".freeze
  DRAW = "0".freeze
  AWAY_WIN = "-1".freeze

  # Métodos de classe para validação
  def self.validate_bet_choices(choices)
    counts = { home_wins: 0, draws: 0, away_wins: 0 }

    choices.each do |choice|
      case choice.to_s
      when HOME_WIN then counts[:home_wins] += 1
      when DRAW then counts[:draws] += 1
      when AWAY_WIN then counts[:away_wins] += 1
      else return false # Opção inválida
      end
    end

    counts[:home_wins] <= 10 && counts[:draws] <= 10 && counts[:away_wins] <= 10
  end

  # Método de compatibilidade com o código antigo
  def self.verificar_aposta(apostas)
    validate_bet_choices(apostas.values)
  end

  private

  def valid_result_combination
    if home == "1" && away == "1"
      errors.add(:base, "Resultado inválido - não pode marcar ambos os times como vencedores")
    elsif home == "1" && away == "-1"
      errors.add(:base, "Resultado inválido - combinação impossível")
    elsif home == "0" && away != "0"
      errors.add(:base, "Para empate, ambos devem ser 0")
    elsif home == "1" && away != "0"
      errors.add(:base, "Para vitória da casa, visitante deve ser 0")
    elsif home == "0" && away == "-1"
      errors.add(:base, "Combinação inválida")
    end
  end

  def limit_bet_types
    return unless rodada

    user_palpites = Palpite.da_rodada(rodada_id).do_usuario(user_id)

    home_wins = user_palpites.where(home: "1", away: "0").count
    draws = user_palpites.where(home: "0", away: "0").count
    away_wins = user_palpites.where(home: "0", away: "-1").count

    if home == "1" && away == "0" && home_wins >= 10
      errors.add(:base, "Limite máximo de 10 vitórias da casa atingido")
    elsif home == "0" && away == "0" && draws >= 10
      errors.add(:base, "Limite máximo de 10 empates atingido")
    elsif home == "0" && away == "-1" && away_wins >= 10
      errors.add(:base, "Limite máximo de 10 vitórias do visitante atingido")
    end
  end
end
