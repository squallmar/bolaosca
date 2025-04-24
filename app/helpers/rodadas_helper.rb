module RodadasHelper
  require "date"

  def date_of_next(day, date_start = Date.today)
    date  = Date.parse(day)
    delta = date > date_start ? 0 : 7
    date + delta
  end

  def comeco_rodada_apostas_default
    date = Date.today.saturday? ? Date.today.to_s : date_of_next("Tuesday").to_s
    date = date.split("-")
    date = Time.new(date[0], date[1], date[2], 00, 00, 0, "-00:00").utc
  end

  def termino_rodada_apostas_default
    date = comeco_rodada_apostas_default.to_date
    date = date_of_next("Sat", date).to_s
    date = date.split("-")
    date = Time.new(date[0], date[1], date[2], 14, 00, 0, "-00:00").utc
  end
end
