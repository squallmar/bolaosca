module PalpitesHelper
  def get_home_on_error(array)
    array.last == "1"
  end

  def get_draw_on_error(array)
    array.last  == "0"
  end

  def get_away_on_error(array)
    array.last == "-1"
  end

  def put_home_on_edit(value)
     value.first > value.last
  end

  def put_draw_on_edit(value)
    value.first  == value.last
  end

  def put_away_on_edit(value)
    value.last > value.first
  end

  def get_data(aposta_home, aposta_away, placar_home, placar_away)
    resultado = placar_home <=> placar_away
    aposta = aposta_home <=> aposta_away
    ponto = 0
    cor_1, cor_2, cor_3 = "transparent", "transparent", "transparent"

    # red
    cor_aux = "#FF8B8B"
    cor_aux_n = "red"

    if aposta == resultado
      ponto = 1

      # green
      cor_aux = "#5ED85E"
      cor_aux_n = "green"
    end

    if resultado == 0
      cor_3 = cor_aux
    elsif resultado > 0
      cor_1 = cor_aux
    else
      cor_2 = cor_aux
    end

    if aposta == 1
      icone_home = "icon-check"
      icone_away = "icon-check-empty"
    elsif aposta == -1
      icone_home =  "icon-check-empty"
      icone_away =  "icon-check"
    else
      icone_away, icone_home = "icon-sign-blank", "icon-sign-blank"
    end
    { cor_1: cor_1, cor_2: cor_2, cor_3: cor_3, icone_home: icone_home, icone_away: icone_away, ponto: ponto, cor_aux: cor_aux_n }
  end

  def get_data_sem_resultado(aposta_home, aposta_away)
    aposta = aposta_home <=> aposta_away
    if aposta == 1
      icone_home = "icon-check"
      icone_away = "icon-check-empty"
    elsif aposta == -1
      icone_home =  "icon-check-empty"
      icone_away =  "icon-check"
    else
      icone_away, icone_home = "icon-sign-blank", "icon-sign-blank"
    end
    { icone_home: icone_home, icone_away: icone_away }
  end
end
