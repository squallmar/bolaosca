# encoding: utf-8



class UsersController < ApplicationController
  before_action :requer_permissao_superadmin, only: [ :index, :destroy, :show, :edit, :update, :alternar_super ]



  def index
    @search_query = params[:q]



    # Filtro base seguro

    @users = if params[:incompletos]

               # Apenas convites não aceitos

               User.where(invitation_accepted_at: nil)

    else

               # Usuários ativos (aceitaram convite OU foram criados diretamente)

               User.where.not(invitation_accepted_at: nil).or(User.where(invited_by_id: nil))

    end



    # Aplica busca se houver termo

    @users = @users.busca_rapida(@search_query) if @search_query.present?
  end



  def show
    get_user
  end



  def edit
    get_user
  end



  def update
    get_user

    if @user.update(user_params)

      flash[:notice] = "Usuário atualizado com sucesso."

      redirect_to @user

    else

      flash.now[:warning] = "O usuário não foi atualizado. Verifique se todos os campos estão preenchidos corretamente."

      render action: "edit"

    end
  end



  def destroy
    get_user

    if @user == current_user

      flash[:warning] = "Você não pode apagar a si mesmo."

      redirect_to users_path

    else

      @user.destroy

      redirect_to users_path, notice: "Usuário apagado com sucesso."

    end
  end



  def alternar_super
    get_user

    if @user == current_user

      flash[:warning] = "Você não pode alterar suas próprias permissões de superadmin."

      redirect_to @user

    else

      @user.alternar_superpoderes

      flash[:notice] = "Permissão alterada com sucesso!"

      redirect_to @user

    end
  end



  private

  def get_user
    @user = User.find(params[:id])
     end



  def user_params
    params.require(:user).permit(:email, :remember_me, :telefone, :nome, :setor, :apelido,

    :avatar, :remove_avatar, :password, :password_confirmation,

    :current_password, :albums, :pontuacaos)
  end
end
