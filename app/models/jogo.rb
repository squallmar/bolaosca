class Jogo < ActiveRecord::Base
  belongs_to :user
  belongs_to :rodada
  has_many :palpites, dependent: :destroy

  TIMES = [
    "ATLÉTICO-MG", "ATLÉTICO-PR", "BAHIA-BA", "BOTAFOGO-RJ", "CORINTHIANS-SP", "CORITIBA-PR", "CRICIÚMA-SC",
    "CRUZEIRO-MG", "FLAMENGO-RJ", "FLUMINENSE-RJ", "GOIÁS-GO", "GRÊMIO-RS", "INTERNACIONAL-RS", "NÁUTICO-PE",
    "PONTE PRETA-SP", "PORTUGUESA-SP", "SANTOS-SP", "SÃO PAULO-SP", "VASCO DA GAMA-RJ", "VITÓRIA-BA",
    "ABC-RN", "AMÉRICA-MG", "AMÉRICA-RN", "ASA-AL", "ATLÉTICO-GO", "AVAÍ-SC", "BOA-MG", "BRAGANTINO-SP",
    "CEARÁ-CE", "CHAPECOENSE-SC", "FIGUEIRENSE-SC", "GUARATINGUETÁ-SP", "ICASA-CE", "JOINVILLE-SC",
    "OESTE-SP", "PALMEIRAS-SP", "PARANÁ-PR", "PAYSANDU-PA", "SÃO CAETANO-SP", "SPORT-PE"
  ].freeze

  validates :time_home, :time_away, presence: true, inclusion: { in: TIMES }
  validate :times_diferentes

  scope :ordenados_por_id, -> { order(id: :asc) }

  before_save :formatar_times
  before_save :ajustar_placares

  def formatar_times
    self.time_home = time_home.to_s.upcase.strip
    self.time_away = time_away.to_s.upcase.strip
  end

  def ajustar_placares
    if !rodada.apostas_encerradas? || placar_home.blank? || placar_away.blank?
      self.placar_home = nil
      self.placar_away = nil
    end
  end

  private

  def times_diferentes
    if time_away.present? && time_home.present? && time_away.casecmp(time_home) == 0
      errors.add(:base, "Times não podem ser iguais")
    end
  end
end
