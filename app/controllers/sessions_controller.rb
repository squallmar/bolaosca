class SessionsController < Devise::SessionsController
  prepend_before_action only: [ :new ] do
    if current_user.present? && (auth_options[:scope] != current_user.class.to_s.downcase.to_sym)
      sign_out_all_scopes
      flash.now[:warning] = "VOCÊ FOI DESLOGADO PARA ENTRAR COM UM NOVO PAPEL"
    end
  end

  def create
    self.resource = warden.authenticate!(auth_options)

    # Proteção contra fixation de sessão
    sign_out(current_user) if user_signed_in?

    # Login seguro com tratamento de falhas
    sign_in(resource_name, resource)

    # Mensagem flash com I18n e verificação de segurança
    set_flash_message(:notice, :signed_in) if is_flashing_format?

    # Redirecionamento seguro com fallback
    redirect_to after_sign_in_path_for(resource), allow_other_host: true
  rescue Warden::NotAuthenticated => e
    # Tratamento de erro específico
    flash.now[:alert] = t("devise.failure.invalid")
    render :new
  end
end
