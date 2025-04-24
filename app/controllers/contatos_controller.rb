# encoding: utf-8



class ContatosController < ApplicationController
  def new
    @contato = Contato.new(request: params[:request])
  end



  def create
    @contato = Contato.new(contato_params)

    if @contato.valid?

      begin

        if @contato.request

          User.com_solicitacoes_cadastro.each do |user|
            NotificationMailer.solicitar_cadastro(@contato, user.email).deliver
          end

        else

          User.com_contatos.each do |user|
            NotificationMailer.contato_geral(@contato, user.email).deliver
          end

        end

        flash[:alert] = "<i class='icon-envelope'>  Mensagem Enviada com sucesso!</i>".html_safe

        redirect_to root_url

      rescue StandardError => e

        Rails.logger.error "Erro ao enviar e-mail: #{e.message}"

        flash.now[:warning] = "Ocorreu um erro ao enviar a mensagem. Tente novamente mais tarde."

        render action: "new"

      end

    else

      flash.now[:warning] = "Todos campos devem estar preenchidos!"

      render action: "new"

    end
  end



  private



  def contato_params
    params.require(:contato).permit(:nome, :email, :assunto, :texto, :request)
  end
end
