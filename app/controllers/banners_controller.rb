# encoding: utf-8

class BannersController < ApplicationController
  before_action :requer_permissao_superadmin, except: [ :link ]

  def link
    @banner = Banner.find_by(id: params[:id])
    if @banner
      views = @banner.count_views.nil? ? 1 : @banner.count_views + 1
      @banner.update_attribute(:count_views, views)
      redirect_to @banner.link
    else
      redirect_to banners_path, alert: "Banner não encontrado."
    end
  end

  def index
    @banners = Banner.all
  end

  def show
    @banner = Banner.find_by(id: params[:id])
    redirect_to banners_path, alert: "Banner não encontrado." unless @banner
  end

  def new
    @banner = Banner.new
  end

  def edit
    @banner = Banner.find_by(id: params[:id])
    redirect_to banners_path, alert: "Banner não encontrado." unless @banner
  end

  def create
    @banner = Banner.new(banner_params)

    if @banner.save
      redirect_to @banner, notice: "Banner foi adicionado com sucesso."
    else
      render action: "new"
    end
  end

  def update
    @banner = Banner.find_by(id: params[:id])
    if @banner&.update(banner_params)
      redirect_to @banner, notice: "Banner atualizado com sucesso."
    else
      flash.now[:warning] = "Banner não foi atualizado, por favor, verifique se há erros no formulário."
      render action: "edit"
    end
  end

  def destroy
    @banner = Banner.find_by(id: params[:id])
    if @banner
      @banner.destroy
      redirect_to banners_url, notice: "Banner excluído com sucesso."
    else
      redirect_to banners_url, alert: "Banner não encontrado."
    end
  end

  private

  # Definindo os parâmetros permitidos
  def banner_params
    params.require(:banner).permit(:count_views, :image, :link, :nome, :text, :tipo)
  end
end
