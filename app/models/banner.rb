# encoding: utf-8

class Banner < ActiveRecord::Base
  mount_uploader :image, ImagemUploader

  TIPOS = [ "Apoio", "Patrocinio" ].freeze
  scope :patrocinadores, -> { where(tipo: "Patrocinio") }
  scope :apoiadores, -> { where(tipo: "Apoio") }

  validates :image, :link, :tipo, presence: true
  validates :tipo, inclusion: { in: TIPOS, message: "Tipo deve ser 'Apoio' ou 'Patrocinio'" }
  validate :assegurar_http

  private

  def assegurar_http
    unless link.starts_with?("http://", "https://")
      errors.add(:link, "Link tem que começar com http:// ou https://")
    end
  end
end
