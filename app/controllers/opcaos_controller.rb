# encoding: utf-8



class OpcaosController < ApplicationController
  before_action :authenticate_user!



  def edit
    @opcao = current_user.opcao

    redirect_to root_path, alert: "Preferências não encontradas." unless @opcao
  end



  def update
    @opcao = current_user.opcao

    if @opcao.update(opcao_params)

      flash[:alert] = "Suas preferências foram salvas com sucesso!"

      redirect_to previous_url

    else

      render action: "edit"

    end
  end



  private



  def opcao_params
    params.require(:opcao).permit(:notificacao_contato_geral, :notificacao_novos_boloes, :notificacao_prazos, :notificacao_solicitar_cadastro, :notificacao_pontuacao, :mostrar_email)
  end
end
