class PalpitesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_bolao_and_rodada
  before_action :verificar_user_inscrito_em_bolao
  before_action :verificar_rodada_com_apostas_nao_encerradas, except: [ :index ]
  before_action :get_palpites, except: [ :create, :index ]
  before_action :verificar_aposta, only: [ :create, :update ]

  def index
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    @palpites = @user.palpites.da_rodada(@rodada.id).to_a
    @jogos = @rodada.jogos.order(:id)
    @pontuacao = Pontuacao.na_rodada(@rodada.id).find_by(user_id: @user.id)&.pontos || 0

    if @palpites.empty?
      flash[:warning] = "Nenhum palpite encontrado para esta rodada."
      redirect_to [ @bolao, @rodada ]
    end
  end

  def new
    edit unless @palpites.present?
    @palpites_form = flash[:data] if flash[:data].present?
    @palpites = current_user.palpites.da_rodada(@rodada.id)
    @rodada.jogos.each do |jogo|
      unless @palpites.any? { |p| p.jogo_id == jogo.id }
        @palpites += [ current_user.palpites.build(
          jogo_id: jogo.id,
          rodada_id: @rodada.id,
          user_id: current_user.id,
          bolao_id: @bolao.id

        ) ]

      end
    end
  end

  def edit
    @palpites_form = flash[:data] if flash[:data].present?

    if @palpites.empty?
      flash[:warning] = "Ainda não adicionou nenhum palpite! <br><br> <a class='btn icon-legal icon-white btn-success' href='#{apostando_bolao_rodada_palpites_path(@bolao, @rodada)}'>Apostar</a>".html_safe
      redirect_to [ @bolao, @rodada ]
    end
  end

  def create
    @erros = []
    @jogos = @rodada.jogos

    @jogos.each do |jogo|
      resultado = params[:palpites][jogo.id.to_s]
      next unless resultado

      home = "0"
      away = "0"
      home = "1" if resultado == "1"
      away = "1" if resultado == "-1"

      palpite = current_user.palpites.create(
        away: away,
        home: home,
        rodada_id: @rodada.id,
        jogo_id: jogo.id,
        bolao_id: @bolao.id
      )

      @erros << palpite.errors.full_messages unless palpite.persisted?
    end

    if @erros.empty?
      flash[:notice] = "<b><i class='icon-beer icon-2x'> APOSTAS FEITAS COM SUCESSO!!! Boa Sorte!</b></i></H2><p> LEMBRANDO QUE VOCÊ AINDA PODERÁ ALTERÁ-LAS ATÉ A HORA DE FECHAMENTO DE APOSTAS.".html_safe
    else
      flash[:warning] = "Partidas não foram atualizadas pois contêm erros: <br><br>#{@erros.join('<br>')}".html_safe
    end

    redirect_to bolao_rodada_palpites_path(@bolao, @rodada)
  end

  def update
    puts "PARAMS RECEBIDOS: #{params[:palpites].inspect}"
    @erros = []

    params[:palpites].each do |jogo_index, resultado|
      jogo = @rodada.jogos[jogo_index.to_i]
      palpite = current_user.palpites.find_or_initialize_by(jogo_id: jogo.id)

      case resultado
      when "1"  # Vitória casa
        palpite.update!(home: 1, away: 0)
      when "0"  # Empate
        palpite.update!(home: 0, away: 0)
      when "-1" # Vitória visitante
        palpite.update!(home: 0, away: -1)
      end
    rescue => e
      @erros << "Jogo #{jogo.id}: #{e.message}"
    end

    if @erros.empty?
      redirect_to bolao_rodada_palpites_path(@bolao, @rodada),
        notice: "Palpites atualizados!"
    else
      flash[:error] = "Erros: #{@erros.join(', ')}"
      redirect_to edit_bolao_rodada_palpites_path(@bolao, @rodada)
    end
  end

  private

  def get_bolao_and_rodada
    @bolao = Bolao.friendly.find(params[:bolao_id])
    @rodada = @bolao.rodadas.friendly.find(params[:rodada_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Bolão ou rodada não encontrados."
  end

  def verificar_user_inscrito_em_bolao
    unless @bolao.users.include?(current_user)
      redirect_to root_path, alert: "Você não está inscrito neste bolão."
    end
  end

  def verificar_rodada_com_apostas_nao_encerradas
    return unless @rodada.apostas_encerradas?
    redirect_to [ @bolao, @rodada ], alert: "Período de apostas encerrado. Não é possível alterar palpites."
  end

  def get_palpites
    @palpites = current_user.palpites.da_rodada(@rodada.id)
  end

  def verificar_aposta
    @palpites_form = params.require(:palpites).permit!.to_h

    unless @palpites_form.present? &&
           @palpites_form.keys.size == @rodada.jogos.size &&
           Palpite.validate_bet_choices(@palpites_form.values)

      if @palpites_form.keys.size != @rodada.jogos.size
        message = "Você deve preencher palpites para todos os #{@rodada.jogos.size} jogos."
      else
        message = "Limite excedido: máximo 10 vitórias, 10 empates ou 10 derrotas."
      end

      flash[:error] = message
      flash[:data] = @palpites_form
      redirect_to request.referer || bolao_rodada_palpites_path(@bolao, @rodada)
    end
  end

  def valid_bet_submission?
    @palpites_form.present? &&
      @palpites_form.size == @rodada.jogos.size &&
      Palpite.validate_bet_choices(@palpites_form.values)
  end

  def handle_invalid_submission
    if @palpites_form.size != @rodada.jogos.size
      message = "Você deve preencher palpites para todos os #{@rodada.jogos.size} jogos."
    else
      message = "Limite excedido: máximo 10 vitórias, 10 empates ou 10 derrotas."
    end
    flash[:error] = message
    flash[:data] = @palpites_form
    redirect_to request.referer || bolao_rodada_palpites_path(@bolao, @rodada)
  end
end
