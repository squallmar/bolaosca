# encoding: utf-8

class InvitationsController < Devise::InvitationsController
  def new
    @bolao = Bolao.find(params[:id]) if params[:id].present?
    super
  end

  def create
    resource_params[:email] = resource_params[:email].gsub(/\\r|\\n|\s/, "").split(",")
    @bolao = Bolao.find(params[:bolao_id].first.first) if params[:bolao_id]

    # UNICO EMAIL
    if resource_params[:email].size <= 1
      resource_params[:email] = resource_params[:email].to_s.gsub!(/\[|\"|\]/, "")
      if @bolao.present?
        # VERIFICANDO SE JA EXISTE USUARIO E O CRIANDO, O CONVIDANDO PARA O BOLAO
        self.resource = User.find_by_email resource_params[:email]
        self.resource ||= User.invite!(resource_params, current_inviter)
        size = @bolao.users.size
        @bolao.users << self.resource if self.resource.errors.empty?
        ParticipantesMailer.informar_cadastro(self.resource.id, @bolao.id).deliver unless size == @bolao.users.size
      else
        self.resource = User.invite!(resource_params, current_inviter)
      end

      if resource.errors.empty?
        flash[:notice]="Usuário convidado!"
        # respond_with resource, :location => after_invite_path_for(resource)
        redirect_to @bolao.present? ? bolao_users_path(@bolao.id) : users_path(incompletos: true)
      else
        respond_with_navigational(resource) do
          if @bolao.present?
            flash[:warning] = resource.errors.messages.to_s.gsub!(/\[|\]|\:|\{|\}|\=|\>|\"/, " ")
            redirect_to new_user_invitation_path(id: @bolao)
          else
            render :new
          end
        end
      end

    # MULTIPLOS EMAILS
    else
      @erros, @xucesso = [], []
      resource_params[:email].each do |email|
        if @bolao.present?
          # VERIFICANDO SE JA EXISTE USUARIO E O CRIANDO, O CONVIDANDO PARA O BOLAO
          user = User.find_by_email email
          user ||= User.invite!({ email: email }, current_inviter)
          size = @bolao.users.size
          @bolao.users << user if user.errors.empty?
          ParticipantesMailer.informar_cadastro(user.id, @bolao.id).deliver unless size == @bolao.users.size
        else
          user = User.invite!({ email: email }, current_inviter)
        end
        @erros << email unless user.errors.empty?
        @xucesso << email if user.errors.empty?
      end

      # SETTING ERRORS MESSAGES
      flash[:warning] = "Os seguintes emails não foram convidados pois são inválidos: #{ @erros.uniq!.each { |email| email+' -' } }".gsub(/\[|\]|\:|\{|\}|\=|\>|\"/, " ") unless @erros.empty?
      @xucesso.uniq!
      set_flash_message(:notice, :send_instructions,
                        email: "#{ @xucesso[0..40].each { |email| (email + ' - ') } }, e outros ...".
                        gsub(/\[|\]|\:|\{|\}|\=|\>|\"/, " ")) if @erros.size < resource_params[:email].size

      if @erros.size > 0
        redirect_to @bolao.present? ? new_user_invitation_path(id: @bolao.id) : new_user_invitation_path
      else
        redirect_to @bolao.present? ? bolao_users_path(@bolao.id) : users_path(incompletos: true)
      end
    end
  end

  def update_resource_params
    params.require(:user).permit(:password, :password_confirmation,
                                :invitation_token, :apelido, :nome,
                                :telefone, :setor)
  end
end
