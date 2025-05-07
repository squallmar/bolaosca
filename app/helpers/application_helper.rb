module ApplicationHelper
  # Helper para mostrar erros de formulário com Tailwind CSS
  def error_tag(model, attribute, options = {})
    return unless model.errors[attribute].present?

    default_classes = "mt-1 text-sm text-red-600"
    combined_classes = "#{default_classes} #{options[:class]}".strip

    content_tag(:div, model.errors[attribute].join(", "), class: combined_classes)
  end

  # Verifica se o controller atual está na lista

  def controller?(*controllers)
    controllers.any? { |c| c.to_s == params[:controller] }
  end



  # Verifica se a action atual está na lista

  def action?(*actions)
    actions.any? { |a| a.to_s == params[:action] }
  end



  # URL da imagem padrão (pode ser configurável via ENV)

  def no_image_url
    ENV["DEFAULT_IMAGE_URL"] || image_path("ball.png")
  end

# Mostra situação da rodada conforme perfil do usuário
def situacao(rodada, user = nil)
  user ||= current_user # Usa current_user se nenhum user for passado

  if user.nil?
    rodada.situacao_nao_admin
  elsif user.admin?
    rodada.situacao_admin
  else
    rodada.situacao_nao_admin
  end
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
    text = capture(&block) if block_given?

    options[:class] = [ options[:class], "active" ].compact.join(" ") if current_page?(path)

    link_to(text, path, options)
  end
end
