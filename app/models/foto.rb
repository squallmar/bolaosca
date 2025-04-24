# encoding: utf-8

class Foto < ActiveRecord::Base
  belongs_to :album
  has_many :comentarios, dependent: :delete_all
  mount_uploader :imagem, ImagemUploader

  validates :imagem, presence: true
  validate :verificar_tamanho

  before_destroy :nullify_capa_album

  private

  def nullify_capa_album
    if album.capa_id == id
      album.update(capa_id: nil)
    end
  end

  def verificar_tamanho
    tamanho_maximo = Bolaosca::Application::ESPACO
    if imagem.file.size > tamanho_maximo
      errors.add(:imagem, "Espaço de armazenamento insuficiente!")
    end
  rescue StandardError
    errors.add(:imagem, "Erro ao verificar o tamanho da imagem.")
  end
end
