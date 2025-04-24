class SessionsController < Devise::SessionsController
  prepend_before_action only: [ :new ] do
    if current_user.present? && (auth_options[:scope] != current_user.class.to_s.downcase.to_sym)
      sign_out_all_scopes
      flash.now[:warning] = "VOCÊ FOI DESLOGADO PARA ENTRAR COM UM NOVO PAPEL"
    end
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    redirect_to after_sign_in_path_for(resource)
  end
end
