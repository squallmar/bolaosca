class JogosController < ApplicationController
  before_action :authenticate_user!
  before_action :get_bolao_and_rodada
  before_action :authorize_admin, except: [ :index, :show ]

  def index
    @jogos = @rodada.jogos.order(:created_at)
  end

  def new
    @jogo = @rodada.jogos.build
  end

  def create
    @jogo = @rodada.jogos.build(jogo_params)
    @jogo.user = current_user  #-------- associar o usuário ao jogo!

    if @jogo.save
      redirect_to bolao_rodada_path(@bolao, @rodada), notice: "Jogo criado com sucesso."
    else
      flash[:error] = "Erro ao criar jogo: #{@jogo.errors.full_messages.join(', ')}"
      redirect_to bolao_rodada_path(@bolao, @rodada)
    end
  end

  def edit
    @jogo = @rodada.jogos.find(params[:id])
  end

  def edit_multiplos
    @jogos = @rodada.jogos.order(:created_at)
    if @jogos.empty?
      redirect_to [ @bolao, @rodada ], alert: "Nenhum jogo cadastrado para edição"
    end
  end

  def update
    @jogo = @rodada.jogos.find(params[:id])

    if @jogo.update(jogo_params)
      redirect_to bolao_rodada_path(@bolao, @rodada),
                  notice: "Jogo atualizado com sucesso!"
    else
      flash[:alert] = "Erro ao atualizar jogo: #{@jogo.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def update_multiplos
    @jogos = @rodada.jogos.order(:created_at)
    success_count = 0
    error_messages = []

    params[:jogos].each do |id, jogo_params|
      jogo = @jogos.find(id)
      if jogo.update(jogo_params.permit(:time_home, :time_away, :placar_home, :placar_away))
        success_count += 1
      else
        error_messages << "Jogo #{jogo.id}: #{jogo.errors.full_messages.join(', ')}"
      end
    end

    if error_messages.empty?
      flash[:notice] = "Todos os jogos foram atualizados com sucesso!"
      if @rodada.apostas_encerradas?
        @rodada.calcular_pontuacao(params[:check_email])
        flash[:notice] += " Pontuações recalculadas."
        flash[:notice] += " #{@bolao.users.com_notificacoes_pontuacao.size} participantes notificados." if params[:check_email]
      end
    elsif success_count > 0
      flash[:warning] = "#{success_count} jogos atualizados. Erros: #{error_messages.join('; ')}"
    else
      flash[:error] = "Erros ao atualizar jogos: #{error_messages.join('; ')}"
    end

    redirect_to bolao_rodada_path(@bolao, @rodada)
  end

  def destroy
    @jogo = @rodada.jogos.find(params[:id])

    if @rodada.rodada_trancada?
      flash[:alert] = "Não é possível apagar jogos após o início das apostas."
    elsif @jogo.destroy
      flash[:notice] = "Jogo removido com sucesso."
    else
      flash[:alert] = "Erro ao remover jogo."
    end

    redirect_to bolao_rodada_path(@bolao, @rodada)
  end

  private

  def get_bolao_and_rodada
    @bolao = Bolao.friendly.find(params[:bolao_id])
    @rodada = @bolao.rodadas.find(params[:rodada_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to bolaos_path, alert: "Recurso não encontrado"
  end

  def authorize_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Acesso não autorizado"
    end
  end

  def jogo_params
    params.require(:jogo).permit(:time_home, :time_away, :placar_home, :placar_away)
  end
end
