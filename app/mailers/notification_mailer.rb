# encoding: utf-8

class NotificationMailer < ActionMailer::Base
  default from: "bolaosca@gmail.com"
  default to: "bolaosca@gmail.com"

  def solicitar_cadastro(contato, email)
    @nome = contato.nome
     @email = contato.email
    @texto = contato.texto
    mail subject: "BOLAO-SCA: Solicitação de Cadastro - #{@email}",
         bcc: email
  end

  def contato_geral(contato, email)
    @nome = contato.nome
    @email = contato.email
    @assunto = contato.assunto
    @texto = contato.texto
    mail subject: "BOLAO-SCA: #{@assunto}",
         bcc: email
  end

  def informar_prazos_apostas(bolao, rodada, email, nome)
    @bolao = bolao
    @rodada = rodada
    @email = email
    @nome = nome
    mail bcc: @email,
         subject: "Prazo para apostar na rodada #{@rodada.numero} do #{@bolao.titulo}!"
  end

  def informar_pontuacao_rodada(bolao, rodada, jogador, pontuacao)
    @bolao = bolao
    @rodada = rodada
    @jogador = jogador
    @pontuacao = pontuacao
    mail to: @jogador.email,
         subject: "Pontuação na rodada #{@rodada.numero} do #{@bolao.titulo}!"
  end
end
