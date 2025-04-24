# encoding: utf-8

class AlbumsController < ApplicationController
  before_action :requer_permissao_superadmin, except: [ :index, :show ]
  before_action :authenticate_user!, only: [ :index, :show ]

  def tornar_capa
    @foto = Foto.find_by(id: params[:foto])
    @album = Album.find_by(id: @foto&.album_id)

    if @foto && @album
      @album.update(capa_id: @foto.id)
      flash.now[:slideshow] = "Sua capa foi alterada!"
      redirect_to album_url(@album) + "#&panel1-" + params[:pos].to_s
    else
      flash[:error] = "Foto ou álbum não encontrado."
      redirect_to albums_path
    end
  end

  def index
    @albums = Album.all
  end

  def show
    @album = Album.find_by(id: params[:id])
    if @album
      render action: "edit" if @album.fotos.empty?
    else
      redirect_to albums_path, alert: "Álbum não encontrado."
    end
  end

  def new
    @album = current_user.albums.build
  end

  def edit
    @album = Album.find_by(id: params[:id])
    redirect_to albums_path, alert: "Álbum não encontrado." unless @album
  end

  def create
    @album = current_user.albums.build(album_params)
    if @album.save
      flash.now[:alert] = "Álbum criado com sucesso"
      redirect_to new_album_foto_path(@album)
    else
      render action: "new"
    end
  end

  def update
    @album = Album.find_by(id: params[:id])
    if @album&.update(album_params)
      flash.now[:alert] = "Álbum atualizado com sucesso."
      if @album.fotos.empty?
        redirect_to new_album_foto_path(@album)
      else
        flash.now[:slideshow] = "Álbum atualizado com sucesso."
        render :show
      end
    else
      render action: "edit"
    end
  end

  def destroy
    @album = Album.find_by(id: params[:id])
    if @album
      @album.destroy
      redirect_to albums_path, notice: "Álbum excluído com sucesso."
    else
      redirect_to albums_path, alert: "Álbum não encontrado."
    end
  end

  private

  def album_params
    params.require(:album).permit(:capa_id, :descricao, :titulo, :capa, :fotos)
  end
end
