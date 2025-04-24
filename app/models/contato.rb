# encoding: utf-8

class Contato
  require "active_support/core_ext/numeric/time"
  include ActiveModel::Validations
  include ActiveModel::Conversion

  extend ActiveModel::Naming
  extend ActiveModel::Translation

  validates :nome, :email, :assunto, :texto, presence: true
  attr_accessor :nome, :email, :assunto, :texto, :request

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validate :solicitacao_email_ja_existente

  def initialize(attributes = {})
    @nome = attributes[:nome]
    @email = attributes[:email]
    @assunto = attributes[:assunto]
    @texto = attributes[:texto]
    @request = attributes[:request] == "true"
  end

  def persisted?
    false
  end

  private
  def solicitacao_email_ja_existente
    errors.add :email, "Email já existente em nossos cadastros" if self.request && User.find_by_email(self.email)
  end
end
