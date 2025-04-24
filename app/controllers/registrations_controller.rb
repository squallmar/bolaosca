# encoding: utf-8

class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!, only: [ :alterar_senha, :alterar_avatar, :edit, :update, :destroy, :show ]

  def alterar_senha
    if current_user
      sign_out_all_scopes
      redirect_to new_password_path(current_user)
    else
      redirect_to new_user_session_path, alert: "Você precisa estar autenticado para alterar a senha."
    end
  end

  def create
    super
  end

  def show
    if current_user
      render "users/show"
    else
      redirect_to new_user_session_path, alert: "Você precisa estar autenticado para acessar esta página."
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if resource_params.present? && resource.update_with_password(resource_params)
      set_flash_message(:notice, update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated) if is_navigational_format?
      bypass_sign_in(resource)
      redirect_to users_show_path
    else
      clean_up_passwords resource
      handle_update_errors
    end
  end

  private

  def handle_update_errors
    case params[:commit]
    when "Atualizar"
      flash.now[:warning] = "Os dados não foram atualizados devido a erros no formulário. Verifique os campos preenchidos."
      respond_with resource
    when "Atualizar Senha"
      flash.now[:warning] = "Senhas inválidas. Certifique-se de que as senhas estão preenchidas corretamente."
      render :alterar_senha
    when "Atualizar Avatar"
      flash.now[:warning] = "Senha ou arquivo inválido. Certifique-se de que o arquivo é uma imagem válida (jpg, png, gif) e menor que 1MB."
      render :alterar_avatar
    end
  end
end
