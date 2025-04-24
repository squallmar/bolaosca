# encoding: utf-8

class InvitationsController < Devise::InvitationsController
  def new
    @bolao = Bolao.find_by(slug: params[:id]) || Bolao.find_by(id: params[:id]) if params[:id].present?

    super
  end

  def create
    emails = sanitized_emails

    @bolao = Bolao.find_by(id: params[:bolao_id]) if params[:bolao_id]

    @erros = []

    @xucesso = []

    emails.each do |email|
      user = invite_user(email, @bolao)

      if user.errors.empty?

        @xucesso << email

      else

        @erros << email

      end
    end

    set_flash_messages

    redirect_to appropriate_path
  end







  private







  def sanitized_emails
    resource_params[:email].gsub(/\\r|\\n|\s/, "").split(",").map(&:strip)
  end







  def invite_user(email, bolao)
    user = User.find_by_email(email) || User.invite!({ email: email }, current_inviter)



    if bolao.present?



      size = bolao.users.size



      bolao.users << user if user.errors.empty?



      ParticipantesMailer.informar_cadastro(user.id, bolao.id).deliver unless size == bolao.users.size



    end



    user
  end







  def set_flash_messages
    flash[:notice] = "Usuário(s) convidado(s) com sucesso!" if @xucesso.any?



    flash[:warning] = "Os seguintes e-mails não foram convidados: #{@erros.join(', ')}" if @erros.any?
  end







  def appropriate_path
    if @erros.any?



      @bolao.present? ? new_user_invitation_path(id: @bolao.id) : new_user_invitation_path



    else



      @bolao.present? ? bolao_users_path(@bolao.id) : users_path(incompletos: true)



    end
  end
end
