module ComentariosHelper
  def pode_apagar?(comentario)
    comentario.user == current_user or admin?
  end
end
