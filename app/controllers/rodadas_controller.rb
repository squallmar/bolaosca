# encoding: utf-8

class RodadasController < ApplicationController
  before_action :get_bolao
  before_action :requer_permissao_superadmin, except: [ :index, :show, :classificacao ]

  def index
    @rodadas = @bolao.rodadas
  end

  def show
    @bolao = Bolao.friendly.find(params[:bolao_id])
    @rodada = @bolao.rodadas.friendly.find(params[:id])
    @ultima_rodada_aberta = Rodada.do_bolao(@bolao.id)
                                 .where("data_final_apostas > ?", Time.now)
                                 .order(:data_inicio_apostas)
                                 .first
    # ... resto do código ...
  end

  def new
    @rodada = @bolao.rodadas.build
  end

  def edit
    @rodada = @bolao.rodadas.find(params[:id])
  end

  def create
    @rodada = @bolao.rodadas.build(rodada_params)
    @rodada.user_id = current_user.id
    if @rodada.save
      flash[:notice] = "Rodada foi criada com sucesso."
      redirect_to [ @bolao, @rodada ]
    else
      flash.now[:warning] = "Rodada não foi criada. Há erros no formulário."
      render action: "new"
    end
  end
  def update
    @rodada = @bolao.rodadas.find(params[:id]) # Busca pelo ID normal

    if @rodada.update(rodada_params)
      flash[:notice] = "Rodada foi atualizada com sucesso."
      redirect_to bolao_rodadas_path(@bolao)
    else
      render :edit
    end
  end

  def destroy
    @rodada = @bolao.rodadas.find(params[:id])
    unless @rodada.rodada_trancada?
      @rodada.destroy
      flash[:warning] = "Rodada removida com sucesso"
      redirect_to @bolao
    else
      flash[:warning] = "<b><i class='icon-warning-sign icon-red icon-2x'> ALERTA DE SEGURANÇA</b></i><br><b>Rodada não pode ser apagada pois as apostas já começaram!</b><br>Não é recomendado, mas se quiser apagar esse registro de rodada, edite a data de ínicio das apostas.".html_safe
      redirect_to [ @bolao, @rodada ]
    end
  end


  def classificacao
    @rodada = @bolao.rodadas.find(params[:id])
    @classificacao = Pontuacao.na_rodada(@rodada)
  end

  def notificar_participantes
    @rodada = @bolao.rodadas.find(params[:id])
    @bolao.users.com_notificacoes_prazos.each do |user|
      NotificationMailer.informar_prazos_apostas(@bolao, @rodada, user.email, user.nome).deliver
    end
    flash[:alert] = "#{@bolao.users.com_notificacoes_prazos.size} participante(s) do bolão foram notificados sobre o prazo das apostas!"
    redirect_to [ @bolao, @rodada ]
  end

  private

  def get_bolao
    @bolao = Bolao.friendly.find(params[:bolao_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Bolão não encontrado"
    redirect_to bolaos_path
  end

  def rodada_params
    params.require(:rodada).permit(
      :numero,
      :data_inicio_apostas,
      :data_final_apostas
    )
  end
end
