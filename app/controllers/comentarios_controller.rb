# encoding: utf-8

class ComentariosController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :new, :destroy ]

  def create
    @post = Post.find(params[:post_id])
    @comentario = @post.comentarios.build(comentario_params)
    @comentario.user = current_user
    if @comentario.save
      flash[:notice] = "Seu comentário foi criado com sucesso!"
    else
      flash[:warning] = "Seu comentário não foi salvo, pois estava vazio!"
    end
    redirect_to @post
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comentario = @post.comentarios.find(params[:id])
    if admin? || @comentario.user == current_user
      @comentario.destroy
      flash[:notice] = "Comentário apagado com sucesso!"
    else
      flash[:warning] = "Você não tem permissão para apagar esse comentário."
    end
    redirect_to @post
  end

  def new
    @comentario = Comentario.new
  end

  private

  def comentario_params
    params.require(:comentario).permit(:texto)
  end
end
