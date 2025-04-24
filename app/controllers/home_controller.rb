# encoding: utf-8

class HomeController < ApplicationController
  skip_before_action :requer_permissao_superadmin

  def index
    @bolao = Bolao.com_datas_iniciais_passadas.first
    @post = Post.first
    @current_round = Rodada.find_by(aberta: true)

    if @bolao.present? && @current_round.present?
      @classificacao = @bolao.get_classificacao(top: "10") unless @bolao.rodadas.empty?
    end
  end


  def noticiasge
    require "rss"
    @news = RSS::Parser.parse(open("http://globoesporte.globo.com/Esportes/Rss/0,,AS0-9827,00.xml").read, true)
  end
end
