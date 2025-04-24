module ApplicationHelper
  # Helper para mostrar erros de formulário
  def error_tag(model, attribute)
    return unless model.errors[attribute].present?

    content_tag :div, model.errors[attribute].first,
                class: "error_message text-red-500 text-sm mt-1"
  end

  # Verifica se o controller atual está na lista
  def controller?(*controllers)
    controllers.any? { |c| c.to_s == params[:controller] }
  end

  # Verifica se a action atual está na lista
  def action?(*actions)
    actions.any? { |a| a.to_s == params[:action] }
  end

  # URL da imagem padrão
  def no_image_url
    asset_pack_path("media/images/ball.png") # Se usar Webpacker/Shakapacker
    # Ou se não usar:
    # image_path('ball.png')
  end

  # Mostra situação da rodada conforme perfil
  def situacao(rodada)
    current_user.admin? ? rodada.situacao_admin : rodada.situacao_nao_admin
  end

  # Helper para ordenação de tabelas
  def sortable(column, title = nil)
    title ||= column.to_s.titleize
    css_class = column.to_s == params[:col] ? "current #{params[:dir]}" : nil
    direction = (column.to_s == params[:col]) && (params[:dir] == "asc") ? "desc" : "asc"

    link_to title, request.params.merge(col: column, dir: direction), class: css_class
  end

  # NOVO HELPER PARA LINKS DE NAVEGAÇÃO
  def nav_link_to(text, path, options = {}, &block)
    if block_given?
      options = path
      path = text
      text = capture(&block)
    end

    options[:class] ||= ""
    options[:class] += " active" if current_page?(path)
    options[:class].strip!

    link_to(text, path, options)
  end
end
