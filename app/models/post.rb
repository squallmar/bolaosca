# encoding: utf-8

class Post < ActiveRecord::Base
  extend FriendlyId

  has_many :comentarios, dependent: :delete_all

  mount_uploader :imagem, PostImagemUploader

  scope :recentes, -> { order(created_at: :desc) }

  validates :texto, :titulo, :slug, presence: true
  validate :verificar_tamanho

  friendly_id :titulo, use: %i[slugged history]

  def verificar_tamanho
    errors.add :imagem, "Espaço de armazenamento insuficiente!" if `du -shk .`.split(/\D/).first.to_i > Bolaosca::Application::ESPACO
  end
end
