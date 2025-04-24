class BolaosController < ApplicationController
  before_action :requer_permissao_superadmin, except: [ :index, :show, :classificacao ]
  before_action :encontrar_bolao, only: [ :show, :edit, :update, :destroy, :classificacao, :adicionar_usuario ]

  def index
    @bolaos = if admin?
                Bolao.all.order(created_at: :desc)
    else
                Bolao.disponiveis.order(data_inicio: :desc)
    end.to_a # Garante que será um array vazio se não houver resultados
  end

  def create
    @bolao = current_user.bolaos.build(bolao_params)

    if @bolao.save
      # Auto-adiciona o criador como participante
      @bolao.users << current_user unless @bolao.users.include?(current_user)

      flash[:notice] = "Bolão criado com sucesso!"
      redirect_to @bolao
    else
      flash[:warning] = "Erros no formulário: #{@bolao.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def update
    if @bolao.update(bolao_params)
      flash[:notice] = "Bolão atualizado!"
      redirect_to @bolao
    else
      flash[:warning] = "Erros na atualização: #{@bolao.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    if @bolao.destroy
      redirect_to bolaos_url, notice: "Bolão excluído permanentemente."
    else
      redirect_to @bolao, alert: "Falha ao excluir: #{@bolao.errors.full_messages.join(', ')}"
    end
  end

  def adicionar_usuario
    usuario = User.find(params[:user_id])

    if @bolao.users.include?(usuario)
      redirect_to @bolao, alert: "Usuário já é participante."
    elsif @bolao.users << usuario
      redirect_to @bolao, notice: "Usuário adicionado!"
    else
      redirect_to @bolao, alert: "Falha ao adicionar usuário."
    end
  end

  private

  def encontrar_bolao
    @bolao = Bolao.includes(:users, :rodadas).friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    available = Bolao.disponiveis.pluck(:titulo)
    redirect_to bolaos_path,
                alert: "Bolão não encontrado. Disponíveis: #{available.join(', ')}"
  end

  def bolao_params
    params.require(:bolao).permit(
      :data_final, :data_inicio, :titulo, :image, :status, :remove_image,
      :user_id, user_ids: []
    )
  end
end
