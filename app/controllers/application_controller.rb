# encoding: UTF-8

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  protect_from_forgery
  before_action :store_location
  before_action :authenticate_user!, only: [ :requer_permissao_superadmin, :verificar_user_inscrito_em_bolao ]
  before_action :requer_permissao_superadmin, only: [ :verificar_user_inscrito_em_bolao ]
  helper_method :admin?, :banners_patrocinadores, :banners_apoiadores, :bolao_atual,
                :rodada_atual, :ultima_rodada_aberta

  delegate :bolao_atual, to: :Bolao
  delegate :ultima_rodada_aberta, :rodada_atual, to: :Rodada

  IGNORED_PATHS = %w[/login /password /invitation].freeze

  def store_location
    session[:previous_urls] ||= [ nil, nil ]
    unless IGNORED_PATHS.any? { |path| request.fullpath.include?(path) }
      session[:previous_urls][1] = session[:previous_urls][0]
      session[:previous_urls][0] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    # Primeiro tenta usar algum redirecionamento armazenado
    if stored_location = stored_location_for(resource)
      stored_location
    # Se o usuário tem bolaos associados
    elsif resource.bolaos.any?
      # Pega o primeiro bolao e redireciona para sua página
      bolao_path(resource.bolaos.first.id)
    else
      # Fallback seguro - redireciona para a página inicial
      # Você pode trocar por outra rota como dashboard_path se preferir
      root_path
    end
  end

  def current_url
    session[:previous_urls].first || root_path
  end

  def previous_url
    session[:previous_urls].last || root_path
  end

  def requer_permissao_superadmin
    flash.keep
    unless admin?
      flash[:warning] = "Você precisa estar conectado como superadmin para fazer essa ação"
      render "layouts/denied_permission"
    end
  end

  def verificar_user_inscrito_em_bolao
    if @bolao.nil? || current_user.nil?
      flash[:warning] = "Bolão ou usuário não encontrado."
      redirect_to root_url and return
    end

    unless @bolao.users.include?(current_user)
      flash[:warning] = "Você ainda não está cadastrado nesse bolão."
      redirect_to root_url
    end
  end

  def admin?
    current_user.present? && current_user.admin?
  end

  def banners_patrocinadores
    @banners_patrocinadores ||= Banner.patrocinadores.order(Arel.sql("RANDOM()")).limit(6).to_a
  end

  def banners_apoiadores
    @banners_apoiadores ||= Banner.apoiadores.order(Arel.sql("RANDOM()")).limit(3).to_a
  end

  private

  def record_not_found
    Rails.logger.error "Registro não encontrado: #{params.inspect}"
    flash[:error] = "Registro não encontrado"
    redirect_to root_path
  end
end
