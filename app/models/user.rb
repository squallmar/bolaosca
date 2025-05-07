# encoding: utf-8

class User < ActiveRecord::Base
  # Associações
  has_and_belongs_to_many :bolaos, -> { distinct }
  has_many :palpites, dependent: :delete_all
  has_many :comentarios, dependent: :delete_all
  has_many :albums, dependent: :destroy
  has_many :pontuacaos, dependent: :delete_all
  has_one :opcao, autosave: true, dependent: :delete

  # Devise Modules
  devise :database_authenticatable,
         :invitable, # Mantém o sistema de convites
         :trackable,
         :rememberable,
         :recoverable,
         :timeoutable,
         validate_on_invite: true # Nova opção para validar ao convidar

  # Uploader
  mount_uploader :avatar, AvatarUploader

  # Scopes
  scope :admins, -> { where(admin: true) }
  scope :com_contatos, -> { admins.joins(:opcao).merge(Opcao.recebe_contatos) }
  scope :com_solicitacoes_cadastro, -> { admins.joins(:opcao).merge(Opcao.recebe_solicitacoes_cadastro) }
  scope :com_notificacoes_novos_boloes, -> { joins(:opcao).merge(Opcao.recebe_notificacoes_novos_boloes) }
  scope :com_notificacoes_prazos, -> { joins(:opcao).merge(Opcao.recebe_notificacoes_prazos) }
  scope :com_notificacoes_pontuacao, -> { joins(:opcao).merge(Opcao.recebe_notificacoes_pontuacao) }
  scope :without_user, ->(user) { user ? where.not(id: user.id) : all }

  # Atributos virtuais
  attr_accessor :current_password

  # Validações
  validates :nome, :telefone, :apelido, presence: true, on: :update
  validates :email, presence: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP },
                   uniqueness: { case_sensitive: false }
  validates :apelido, uniqueness: { on: :update }
  validates :telefone, format: { with: /\A\(\d{2}\) \d{4,5}-\d{4}\z/ }, allow_blank: true, on: :update
  validate :verificar_tamanho_avatar, on: :update

  # Callbacks
  after_create :criar_preferencias
  after_invitation_accepted :enviar_notificacao_ativacao

  # Métodos
  def self.busca_rapida(texto)
    return all unless texto.present?
    where("unaccent(email) ILIKE unaccent(:texto) OR
           unaccent(nome) ILIKE unaccent(:texto) OR
           unaccent(apelido) ILIKE unaccent(:texto)", texto: "%#{texto}%")
  end

  def alternar_superpoderes
    toggle!(:admin)
  end

  def update_with_password(params = {})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update(params)
  end

  def nome_exibicao
    apelido.presence || nome.split.first
  end

  private

  def criar_preferencias
    create_opcao(
      notificacao_contato_geral: true,
      notificacao_novos_boloes: true,
      notificacao_prazos: true,
      notificacao_solicitar_cadastro: true,
      notificacao_pontuacao: true
    )
  end

  def verificar_tamanho_avatar
    return unless avatar_changed?
    if `du -shk .`.split(/\D/).first.to_i > Bolaosca::Application::ESPACO
      errors.add(:avatar, "Espaço de armazenamento insuficiente!")
    end
  end

  def enviar_notificacao_ativacao
    AdministradoresMailer.novo_usuario_ativado(self).deliver_later
  end
end
