# encoding: utf-8

class User < ActiveRecord::Base
  has_and_belongs_to_many :bolaos, uniq: true

  has_many :bolaos
  has_many :palpites, dependent: :delete_all
  has_many :comentarios, dependent: :delete_all
  has_many :albums, dependent: :destroy
  has_many :pontuacaos, dependent: :delete_all
  has_one :opcao, autosave: true, dependent: :delete

  # Include default devise modules
  devise :database_authenticatable, :invitable, :trackable, :rememberable, :recoverable, :timeoutable

  mount_uploader :avatar, AvatarUploader

  scope :admins, -> { where(admin: true) }
  scope :com_contatos, -> { admins.joins(:opcao).merge(Opcao.recebe_contatos) }
  scope :com_solicitacoes_cadastro, -> { admins.joins(:opcao).merge(Opcao.recebe_solicitacoes_cadastro) }
  scope :com_notificacoes_novos_boloes, -> { joins(:opcao).merge(Opcao.recebe_notificacoes_novos_boloes) }
  scope :com_notificacoes_prazos, -> { joins(:opcao).merge(Opcao.recebe_notificacoes_prazos) }
  scope :com_notificacoes_pontuacao, -> { joins(:opcao).merge(Opcao.recebe_notificacoes_pontuacao) }
  scope :without_user, ->(user) { user ? where.not(id: user.id) : all }

  attr_accessor :current_password

  validates :nome, :telefone, :apelido, presence: true, on: :update
  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }
  validates_uniqueness_of :apelido, on: :update
  validate :verificar_tamanho

  after_create :criar_preferencias

  def verificar_tamanho
    errors.add :avatar, "Espaço de armazenamento insuficiente!" if `du -shk .`.split(/\D/).first.to_i > Bolaosca::Application::ESPACO
  end

  def self.busca_rapida(texto)
    return all unless texto.present?
    where("email LIKE :texto OR nome LIKE :texto OR apelido LIKE :texto",
          texto: "%#{texto}%")
  end

  def alternar_superpoderes
    toggle!(:admin)
  end

  def update_with_password(params = {})
    if params[:password].blank? && params[:current_password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update(params)
  end

  def criar_preferencias
    create_opcao(
      notificacao_contato_geral: true,
      notificacao_novos_boloes: true,
      notificacao_prazos: true,
      notificacao_solicitar_cadastro: true,
      notificacao_pontuacao: true
    )
  end
end
