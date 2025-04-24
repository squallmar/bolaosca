# encoding:utf-8

class FotosController < ApplicationController
  before_action :requer_permissao_superadmin

  before_action :get_album



  def new
    @foto = @album.fotos.build
  end



  def create
    desc = params[:foto].first[:descricao] ||= @album.titulo

    imagens = params[:imagem]

    if imagens.nil?

      flash.now[:alert] = "Não há fotos escolhidas"

      return redirect_to new_album_foto_path(@album)

    end

    @erros = []

    imagens.each do |imagem|
      @erros << 1 unless @album.fotos.create({ imagem: imagem, descricao: desc })
    end



    if @erros.size == imagens.size

      flash.now[:alert] = "Suas fotos não foram adicionadas!"

      render :new

    else

      flash[:slideshow] = ""

      flash[:slideshow] += '<i class="icon-beer ">  Suas fotos foram adicionadas com sucesso!</i><br>' if @erros.size < imagens.size

      flash[:slideshow] += '<i class="icon-frown">  Algumas fotos não foram adicionadas!</i></br>' unless @erros.empty?

      flash[:slideshow] = flash[:slideshow].html_safe

      redirect_to @album

    end
  end



  def edit
    @foto = Foto.find(params[:id])
  end



  def update
    @foto = Foto.find(params[:id])

    if @foto.update(foto_params)

      flash.now[:notice] = "Foto atualizada com sucesso."

      redirect_to @album

    else

      flash.now[:warning] = "Há erros no formulário"

      render :edit

    end
  end



  def destroy
    @foto = Foto.find_by(id: params[:id])

    if @foto

      @album.capa_id = nil if @foto.id == @album.capa_id

      @foto.destroy

      flash.now[:notice] = "Foto apagada com sucesso."

    else

      flash.now[:alert] = "Foto não encontrada."

    end

    redirect_to @album
  end



  private



  def get_album
    flash.keep

    @album = Album.find_by(id: params[:album_id])

    redirect_to albums_path, alert: "Álbum não encontrado." unless @album
  end



  def foto_params
    params.require(:foto).permit(:descricao, :imagem, :album)
  end
end
