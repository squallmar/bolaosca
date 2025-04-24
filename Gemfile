source "https://rubygems.org"

# Versão estável mais recente do Rails (7.1.3.2 em junho/2024)
gem "rails", "~> 8.0.2"

# Banco de dados
gem "sqlite3", ">= 1.4"

# Servidor web
gem "puma", ">= 6.0"

# Sistema de assets (escolha UM dos dois abaixo)
gem "propshaft" # Opção moderna recomendada
gem "rack-cors"


# JavaScript
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"


# Autenticação
gem "devise", "~> 4.9.3"
gem "devise_invitable", "~> 2.0"
gem "bcrypt", "~> 3.1.7"

# Uploads e processamento de imagens
gem "carrierwave"
gem "image_processing", "~> 1.2"
gem "mini_magick" # Alternativa mais leve ao rmagick

# URLs amigáveis
gem "friendly_id", "~> 5.4.0"

# Cache e filas
gem "solid_cache"
gem "solid_queue"

# Windows não inclui arquivos zoneinfo
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Otimização de boot
gem "bootsnap", require: false

# Deploy
gem "kamal", require: false

# Segurança e performance
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "listen", "~> 3.3" # Necessário para auto-reload em desenvolvimento
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "tailwindcss-rails", "~> 4.2"
