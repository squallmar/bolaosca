class Opcao < ActiveRecord::Base
  belongs_to :user

  scope :recebe_contatos, -> { where(notificacao_contato_geral: true) }
  scope :recebe_solicitacoes_cadastro, -> { where(notificacao_solicitar_cadastro: true) }
  scope :recebe_notificacoes_novos_boloes, -> { where(notificacao_novos_boloes: true) }
  scope :recebe_notificacoes_prazos, -> { where(notificacao_prazos: true) }
  scope :recebe_notificacoes_pontuacao, -> { where(notificacao_pontuacao: true) }
end
