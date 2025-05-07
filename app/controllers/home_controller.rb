class HomeController < ApplicationController
  skip_before_action :requer_permissao_superadmin

  def index
    @bolao = Bolao.com_datas_iniciais_passadas.first
    @classificacao = @bolao.get_classificacao(top: "10") if @bolao.present? && @bolao.rodadas.any?
    @post = Post.first
  end

  def noticiasge
    begin
      # Lista de fontes alternativas (prioridade ordenada)
      rss_sources = [
        "https://ge.globo.com/rss/futebol/times/flamengo/",
        "https://www.terra.com.br/esportes/rss.xml",
        "https://www.espn.com.br/espn/rss/news"
      ]

      @news = nil

      # Tenta cada fonte até encontrar uma que funcione
      rss_sources.each do |source|
        response = HTTParty.get(source, timeout: 10, headers: { "User-Agent" => "Mozilla/5.0" })
        next unless response.success?

        begin
          @news = Feedjira.parse(response.body).entries.first(10)
          break if @news.present?
        rescue Feedjira::NoParserAvailable
          next
        end
      end

      if @news.blank?
        flash.now[:alert] = "Não foi possível carregar notícias das fontes disponíveis."
        Rails.logger.warn "Todos os feeds falharam: #{rss_sources}"
        @news = mock_news_data if Rails.env.development?
      end

    rescue StandardError => e
      @news = []
      flash.now[:alert] = "Erro técnico ao carregar notícias."
      Rails.logger.error "Erro RSS: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end

  private

  def mock_news_data
    [
      OpenStruct.new(
        title: "Flamengo vence clássico",
        url: "https://exemplo.com/noticia1",
        summary: "O Flamengo venceu o último clássico por 2x1 com gols de...",
        published: Time.now
      ),
      OpenStruct.new(
        title: "Novo reforço para o time",
        url: "https://exemplo.com/noticia2",
        summary: "O clube anunciou a contratação do jogador...",
        published: Time.now - 2.hours
      )
    ]
  end
end
