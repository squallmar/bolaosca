# encoding: utf-8

class PostsController < ApplicationController
  before_action :requer_permissao_superadmin, only: [ :create, :new, :edit, :update, :destroy ]

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by(id: params[:id])
    redirect_to posts_path, alert: "Postagem não encontrada." unless @post
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find_by(id: params[:id])
    redirect_to posts_path, alert: "Postagem não encontrada." unless @post
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      flash[:notice] = "Postagem feita com sucesso."
      redirect_to @post
    else
      flash.now[:warning] = "Postagem não foi salva. Há erros no formulário."
      render action: "new"
    end
  end

  def update
    @post = Post.find_by(id: params[:id])
    if @post&.update(post_params)
      flash[:notice] = "Postagem atualizada com sucesso."
      redirect_to @post
    else
      flash.now[:warning] = "Postagem não foi salva. Há erros no formulário."
      render action: "edit"
    end
  end

  def destroy
    @post = Post.find_by(id: params[:id])
    if @post
      @post.destroy
      flash[:notice] = "Postagem removida com sucesso."
    else
      flash[:alert] = "Postagem não encontrada."
    end
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:imagem, :texto, :titulo)
  end
end
