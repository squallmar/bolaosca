# encoding: utf-8

class Bolaos::UsersController < ApplicationController
  before_action :requer_permissao_superadmin, except: [ :show, :comparar ]
  before_action :authenticate_user!
  before_action :get_bolao
  before_action :get_user, only: [ :show, :comparar, :destroy ]
  helper_method :sort_column, :sort_direction

  def show
    @order = "#{sort_column} #{sort_direction}"
    load_user_pontuacao
  end

  def comparar
    load_user_pontuacao
    @other_user = find_user_for_comparison

    unless @other_user
      redirect_to [ @bolao, @user ], alert: "Nenhum usuário encontrado para comparação."
      return
    end

    load_comparison_data
  end

  def index
    @search_query = params[:q]
    @users = @bolao.users.busca_rapida(@search_query)
  end

  def inscrever
    unless @user
      redirect_to bolao_participantes_path(@bolao), alert: "Usuário não encontrado."
      return
    end

    if @bolao.users.exists?(@user.id)
      redirect_to bolao_participantes_path(@bolao),
                  alert: "#{@user.apelido || 'Usuário'} já é participante."
    else
      @bolao.users << @user
      redirect_to bolao_participantes_path(@bolao),
                  notice: "#{@user.apelido || 'Usuário'} adicionado com sucesso!"
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to bolao_participantes_path(@bolao),
                alert: "Erro ao adicionar: #{e.message}"
  end

  def destroy
    handle_removal_result
  end

  private

  def get_bolao
    @bolao = Bolao.friendly.find(params[:bolao_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to bolaos_path, alert: "Bolão não encontrado"
  end
end

   def get_user
    @user = User.find_by(id: params[:id])
    unless @user
      redirect_to bolao_participantes_path(@bolao), alert: "Usuário não encontrado."
    end
  end

  def load_user_pontuacao
    @pontuacao_nas_rodadas = @bolao.pontuacaos.unscoped
                                   .do_usuario(@user)
                                   .includes(:rodada)
                                   .order(@order)
    @pontuacao = @pontuacao_nas_rodadas.sum(:pontos)
  end

  def find_user_for_comparison
    @bolao.users.invitation_accepted
          .without_user(@user)
          .busca_rapida(params.dig(:other_user, :user))
          .first
  end

  def load_comparison_data
    @rodadas = Rodada.unscoped.where(bolao_id: @bolao.id).order(@order)
    @other_pontuacao_nas_rodadas = @bolao.pontuacaos.unscoped.do_usuario(@other_user)
    @other_pontuacao = @other_pontuacao_nas_rodadas.sum(:pontos)
  end

  def handle_inscription_result
    if @user.nil?
      redirect_with_alert("Usuário não encontrado ou ainda não aceitou o convite.")
    elsif @bolao.users.exists?(@user.id)
      redirect_with_alert("Usuário já está inscrito no bolão.")
    elsif @bolao.users << @user
      redirect_with_notice("Usuário inscrito no bolão com sucesso.")
    else
      redirect_with_warning("Erro ao inscrever o usuário no bolão.")
    end
  end

  def handle_removal_result
    if @user.nil?
      redirect_to bolao_users_path(@bolao), alert: "Usuário não encontrado no bolão."
    elsif @bolao.users.delete(@user)
      redirect_to bolao_users_path(@bolao), notice: "Usuário removido do bolão com sucesso."
    else
      redirect_to bolao_users_path(@bolao), warning: "Erro ao remover o usuário do bolão."
    end
  end

  def log_bolao_not_found
    logger.error "Bolão não encontrado para ID: #{params[:bolao_id]} - Bolões existentes: #{Bolao.pluck(:id, :titulo)}"
  end

  def redirect_with_bolaos_list
    redirect_to bolaos_path,
                alert: "Bolão não encontrado. Bolões disponíveis: #{Bolao.pluck(:titulo).join(', ')}"
  end

  def redirect_with_alert(message)
    redirect_to users_path, alert: message
  end

  def redirect_with_notice(message)
    redirect_to users_path, notice: message
  end

  def redirect_with_warning(message)
    redirect_to users_path, warning: message
  end

  def sort_column
    %w[rodada_id pontos].include?(params[:col]) ? params[:col] : "rodada_id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
