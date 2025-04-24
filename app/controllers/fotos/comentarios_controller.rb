# encoding: utf-8

class Fotos::ComentariosController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy ]
  before_action :set_foto, only: [ :create, :destroy ]
  before_action :set_comentario, only: [ :destroy ]

  def create
    @comentario = @foto.comentarios.build(comentario_params)
    @comentario.user = current_user

    if @comentario.save
      flash[:notice] = "Seu comentário foi criado com sucesso!"
    else
      flash[:alert] = "Seu comentário não foi gravado, pois estava vazio!"
    end

    redirect_to album_url(@foto.album) + "#&panel1-" + params[:pos].to_s
  end

  def destroy
    if @comentario.user == current_user || admin?
      @comentario.destroy
      flash[:notice] = "Seu comentário foi apagado com sucesso!"
    else
      flash[:alert] = "Você não tem permissão para apagar este comentário."
    end

    redirect_to album_url(@foto.album) + "#&panel1-" + params[:pos].to_s
  end

  private

  def set_foto
    @foto = Foto.find(params[:foto_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url, alert: "Foto não encontrada."
  end

  def set_comentario
    @comentario = @foto.comentarios.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to album_url(@foto.album), alert: "Comentário não encontrado."
  end

  def comentario_params
    params.require(:comentario).permit(:texto)
  end
end
