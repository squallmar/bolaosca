class PalpitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bolao_and_rodada
  before_action :check_user_subscription
  before_action :check_betting_period, except: [ :index ]
  before_action :load_user_bets, except: [ :create, :index ]
  before_action :validate_bets, only: [ :create, :update ]

  def index
    @user = set_view_user
    @bets = @user.bets.for_round(@rodada.id).ordered
    @score = Score.for_round(@rodada.id).find_by(user_id: @user.id)&.points
    @games = @rodada.games.ordered

    if @bets.empty?
      flash[:alert] = "Você ainda não fez palpites para esta rodada!"
      redirect_to new_bolao_rodada_palpites_path(@bolao, @rodada)
    end
  end

  def new
    if @bets.empty?
      @rodada.games.ordered.each do |game|
        @bets << current_user.bets.build(
          game_id: game.id,
          round_id: @rodada.id,
          user_id: current_user.id,
          bolao_id: @bolao.id
        )
      end
    end

    @bet_form = flash[:form_data] if flash[:form_data]
    @games = @rodada.games.ordered
  end

  def create
    @errors = []
    @games = @rodada.games.ordered

    params[:bets].to_unsafe_h.each do |index, value|
      game = @games[index.to_i]

      bet = current_user.bets.find_or_initialize_by(
        game_id: game.id,
        round_id: @rodada.id,
        bolao_id: @bolao.id
      )

      bet.assign_attributes(
        home: value == "1" ? "1" : "0",
        away: value == "-1" ? "1" : "0"
      )

      unless bet.save
        @errors << { game: game.id, error: bet.errors.full_messages.join(", ") }
      end
    end

    handle_flash_messages
    redirect_after_save
  end

  def update
    @errors = []
    @games = @rodada.games.ordered

    params[:bets].to_unsafe_h.each do |index, value|
      bet = @bets[index.to_i]

      unless bet.update(
        home: value == "1" ? "1" : "0",
        away: value == "-1" ? "1" : "0"
      )
        @errors << { game: @games[index.to_i].id, error: bet.errors.full_messages.join(", ") }
      end
    end

    handle_flash_messages
    redirect_after_save
  end

  private

  def set_bolao_and_rodada
    @bolao = Bolao.friendly.find(params[:bolao_id])
    @rodada = @bolao.rounds.friendly.find(params[:rodada_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Bolão ou rodada não encontrados"
  end

  def check_user_subscription
    unless current_user.subscribed_to?(@bolao)
      redirect_to @bolao, alert: "Você precisa estar inscrito no bolão para apostar"
    end
  end

  def check_betting_period
    if @rodada.betting_closed?
      redirect_to bolao_rodada_path(@bolao, @rodada), alert: "Período de apostas encerrado"
    end
  end

  def load_user_bets
    @bets = current_user.bets.for_round(@rodada.id).ordered.to_a
  end

  def validate_bets
    @bet_data = params.require(:bets).to_unsafe_h

    unless @bet_data.present? &&
           @bet_data.size == @rodada.games.size &&
           Bet.valid_choices?(@bet_data.values)
      flash[:alert] = "Palpites inválidos. Verifique suas escolhas."
      flash[:form_data] = @bet_data
      redirect_back fallback_location: root_path
    end
  end

  def set_view_user
    if @rodada.betting_closed? && params[:user_id].present?
      @bolao.users.find(params[:user_id])
    else
      current_user
    end
  end

  def handle_flash_messages
    if @errors.empty?
      flash[:notice] = "Palpites salvos com sucesso!"
    else
      flash[:alert] = "Erros encontrados: #{@errors.map { |e| "Jogo #{e[:game]}: #{e[:error]}" }.join('; ')}"
    end
  end

  def redirect_after_save
    if @errors.empty?
      redirect_to bolao_rodada_path(@bolao, @rodada)
    else
      flash[:form_data] = params[:bets].to_unsafe_h
      redirect_to new_bolao_rodada_palpites_path(@bolao, @rodada)
    end
  end
end
