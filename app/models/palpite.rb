class Palpite < ApplicationRecord
  belongs_to :jogo
  belongs_to :rodada
  belongs_to :user
  belongs_to :bolao

  validates :user_id, uniqueness: { scope: [ :jogo_id, :bolao_id ] }
  validates :home, :away, presence: true
  validate :valid_result

  scope :do_usuario, ->(user_id) { where(user_id: user_id) }
  scope :do_jogo, ->(jogo_id) { where(jogo_id: jogo_id) }
  scope :da_rodada, ->(rodada_id) { where(rodada_id: rodada_id) }
  scope :ordenados, -> { includes(:jogo).order("jogos.data ASC") }

  def self.valid_choices?(choices)
    counts = { home_wins: 0, draws: 0, away_wins: 0 }

    choices.each do |choice|
      case choice.to_i
      when 1 then counts[:home_wins] += 1
      when 0 then counts[:draws] += 1
      when -1 then counts[:away_wins] += 1
      end
    end

    counts[:home_wins] <= 10 && counts[:draws] <= 10 && counts[:away_wins] <= 10
  end

  private

  def valid_result
    if home == "1" && away == "1"
      errors.add(:base, "Resultado inválido - não pode ter dois vencedores")
    end
  end
end
