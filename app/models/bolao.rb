# encoding: utf-8

class Bolao < ActiveRecord::Base
  extend FriendlyId
  friendly_id :titulo, use: [ :slugged, :finders, :history ]

  belongs_to :user
  has_many :rodadas, dependent: :destroy
  has_many :pontuacaos, dependent: :delete_all
  has_many :palpites, through: :rodadas, dependent: :delete_all
  has_and_belongs_to_many :users, -> { distinct },
                          before_remove: ->(bolao, user) do
                            user.pontuacaos.no_bolao(bolao).destroy_all
                            bolao.palpites.do_usuario(user).destroy_all
                          end

  mount_uploader :image, ImagemUploader

  scope :ativos, -> { where(status: "ativo").order(data_inicio: :desc) }
  scope :em_andamento, -> { where("data_final > ? AND data_inicio < ?", Time.current, Time.current) }
  scope :com_datas_iniciais_passadas, -> { where("data_inicio < :agora", agora: Time.current) }

  validates :data_inicio, :data_final, :titulo, :slug, presence: true
  validates :titulo, uniqueness: true
  validate :validar_datas

  friendly_id :titulo, use: %i[slugged history]

  def validar_datas
    if data_final && data_inicio
      errors.add(:data_final, "não pode ser antes da data de início") if data_final < data_inicio
    end
  end

  def get_classificacao(options = {})
    order = options[:order] || "DESC"
    top = options[:top]

    result = pontuacaos
               .select("user_id, SUM(pontos) AS soma, MAX(pontos) AS maximo")
               .group(:user_id)
               .order("soma #{order}, maximo #{order}")
               .limit(top)

    ids = result.map(&:user_id)
    dados = users.where(id: ids).select(:id, :apelido, :email).index_by(&:id)

    result.map do |r|
      r.attributes.merge(dados[r.user_id].attributes)
    end
  end

  def self.bolao_atual
    em_andamento.first || com_datas_iniciais_passadas.first
  end

  def should_generate_new_friendly_id?
    titulo_changed? || super
  end
end
