# encoding: utf-8

class ParticipantesMailer < ActionMailer::Base
  default from: "bolaosca@gmail.com"

  def informar_cadastro(user_id, bolao_id)
    @user = User.find user_id
    @bolao = Bolao.find bolao_id
    mail to: @user.email, subject: "BEM VINDO AO BOLÃO #{@bolao.titulo}"
  end
end
